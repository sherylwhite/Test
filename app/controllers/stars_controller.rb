class StarsController < ApplicationController
  before_filter :login_required
  
  layout 'standard'
  
  def download
    fileName=params[:fname]
    downloadLink='public/files/'+fileName
    send_file(downloadLink)
  end
    
  def upload
     post = Files.save(@params["starsFile"])
     self.genFiles()    
   end
   
  def import
    #post = Files.saveSub(@params["subup"])
    #post = Files.saveGrp(@params["grpup"])
    #post = Files.saveVen(@params["venup"])
    
    IndexSubject.delete_all
    Subject.delete_all
    Venue.delete_all
    LessonGroup.delete_all
    Lesson.delete_all
    SlotAllocation.delete_all
    StaffAssignment.delete_all
    
    ActiveRecord::Base.connection.execute("Alter table lesson_groups AUTO_INCREMENT=1") 
    ActiveRecord::Base.connection.execute("Alter table lessons AUTO_INCREMENT=1") 
    ActiveRecord::Base.connection.execute("Alter table slot_allocations AUTO_INCREMENT=1") 
    ActiveRecord::Base.connection.execute("Alter table staff_assignments AUTO_INCREMENT=1") 
    
    contents=""
    subExcel=File.new("public/files/subjectDetails.xls","r")
    contents=subExcel.read
    subExcel.close
    
    arr = Array.new    
    sub= Array.new
    arr= contents.split("\n")
    
    1.upto(arr.length-1) do |h|
      sub[h] = arr[h].split("\t")
    end
    
    1.upto(sub.length-1) do |h|
      subject = Subject.new
      subject.id=sub[h][0].strip
      subject.subjectName=sub[h][1].strip
      subject.yearOfStudy=sub[h][2].strip
      subject.discipline=sub[h][3].strip
      subject.acad_unit=sub[h][4].strip
      subject.cohort_size=sub[h][5].strip
      subject.remarks=sub[h][6]
      if subject.remarks==nil
        subject.remarks=""
      end      
      subject.save        
    end
    
    contents=""
    lessonGrpExcel=File.new("public/files/lessonGroupDetails.xls","r")
    contents=lessonGrpExcel.read
    lessonGrpExcel.close
    
    arr.clear  
    les_grp= Array.new
    arr= contents.split("\n")
    
    1.upto(arr.length-1) do |h|
      les_grp[h] = arr[h].split("\t")
    end
    
    1.upto(les_grp.length-1) do |h|
      group_index=les_grp[h][0].strip
      group_size=les_grp[h][1].strip
      
      leng=group_index.length
      gr=group_index[leng-2,2]
      if gr.to_i==0
        group_prefix=group_index[0,leng-1]
        group_no=group_index[leng-1,1]
        if group_no.to_i==0
          group_prefix=group_index
          group_no=0
        end
      else
        group_prefix=group_index[0,leng-2]
        group_no=gr
      end
      
      grp=LessonGroup.new
      grp.groupIndex=group_index
      grp.groupPrefix=group_prefix
      grp.groupNo=group_no
      grp.groupSize=group_size
      grp.save      
    end
    
    contents=""
    venExcel=File.new("public/files/venueDetails.xls","r")
    contents=venExcel.read
    venExcel.close
    
    arr.clear  
    ven= Array.new
    arr= contents.split("\n")
    
    1.upto(arr.length-1) do |h|
      ven[h] = arr[h].split("\t")
    end
    
    1.upto(ven.length-1) do |h|
      vname=ven[h][0].strip
      vcap=ven[h][1].strip
      vrem=ven[h][2]
      if vrem==nil
        vrem=""
      else
        vrem=ven[h][2].strip
      end
       
      if vname[0,2]=="TR" 
        vtype="Tut"
      elsif vname[0,2]=="LT" 
        vtype="Lec"
      else
        vtype="Lab"
      end
      
      venue=Venue.new
      venue.id=vname
      venue.venueType=vtype
      venue.capacity=vcap
      venue.remarks=vrem
      venue.save      
    end
    
    file = File.new("public/files/latestSTARS.txt","r")
    entries = Array.new
    x=0
    while(line=file.gets)
      if line.strip!=""
        entries[x]=line.strip
        x +=1
      end
    end
    file.close
    entries.sort
    
    0.upto(entries.length-1) do |y|
      
      theData=entries[y]
      subcode=theData[5,6].strip
      groupIndex=theData[14,5].strip
      type=theData[11,3].strip
      venue=theData[31,20].strip
      day=theData[19,2].strip
      startT=theData[21,5].strip
      endT=theData[26,5].strip
      
      if type=="LEC"
        nof=3
        posVenues=venue
      elsif type=="TUT"
        posVenues="TR7,TR8,TR9,TR10,TR11,TR12,TR13,TR14,TR15,TR16,TR17,TR18,TR19,TR20,TR21,TR22,TR23,TR24,TR26,TR39,TR41,TR49,TR50" 
        if posVenues.include?(venue)==false
          posVenues = venue + "," + posVenues
        end
        nof=1
      else
          posVenues=venue
          nof=1
      end
    
    if day=="M" 
      day="Monday"
    elsif day=="T"
      day="Tuesday"
    elsif day=="W"
      day="Wednesday"
    elsif day=="TH"
      day="Thursday"
    elsif day=="F"
      day="Friday"
    else
      day="Saturday"
    end
    
    remark=""
    1.upto(13) do|w|
      if theData[50+w,1]!="N"
        remark+=w.to_s+","
      end
    end
    
    remark=remark[0,remark.length-1]
    weeks="1,2,3,4,5,6,7,8,9,10,11,12,13"
    wklen=weeks.length
    rmlen=remark.length
    
    if rmlen!=wklen
      allocfreq="Weekly"
      if rmlen==13
        if remark[0,1].to_s!="2" 
          allocfreq="Odd"
        else
          allocfreq="Even"
        end
      elsif rmlen==15
        allocfreq="Odd"
      end
      freq="Altern"
    else
      freq="Weekly"
      allocfreq="Weekly"
    end
    
    query=Lesson.find_by_sql("Select lessonId from lessons where subjectCode='#{subcode}' And lessonType='#{type}'")
    if query[0]==nil
      lesson=Lesson.new
      lesson.subjectCode=subcode
      lesson.lessonType=type
      lesson.noOfLesson=nof
      lesson.frequency=freq
      lesson.lessonGroupsAssigned=groupIndex
      lesson.possibleVenues=posVenues
      lesson.save
      query=Lesson.find_by_sql("Select lessonId from lessons where subjectCode='#{subcode}' And lessonType='#{type}'")
      lessonid=query[0].lessonId
    else
      lessonid=query[0].lessonId
      if Lesson.find(lessonid).possibleVenues.include?(posVenues)==false
        posVen2=Lesson.find(lessonid).possibleVenues+","+venue
        Lesson.find(lessonid).update_attribute :possibleVenues, posVen2
      end
      if Lesson.find(lessonid).lessonGroupsAssigned.include?(groupIndex)==false
        new_lg_assigned=Lesson.find(lessonid).lessonGroupsAssigned+","+groupIndex
        Lesson.find(lessonid).update_attribute :lessonGroupsAssigned, new_lg_assigned
      end    
    end
    
    groupid=LessonGroup.find(:first,:conditions=>"groupIndex = '#{groupIndex}'").groupId
    
    query=StaffAssignment.find_by_sql("Select assignId from staff_assignments where groupId =#{groupid} And lessonId=#{lessonid}")
    if query[0]==nil
      sta=StaffAssignment.new
      sta.groupId=groupid
      sta.lessonId=lessonid
      sta.staffId=0
      sta.teachLessonWeek=remark
      sta.save
    end
        
    while(startT<endT)
      query=TimeSlot.find_by_sql("Select timeSlotId from time_slots where startTime='#{startT}' And dayOfWeek='#{day}'")
      timeid=query[0].timeSlotId
      sa=SlotAllocation.new
      sa.lessonId=lessonid
      sa.groupId=groupid
      sa.venueName=venue
      sa.timeSlotId=timeid
      sa.alloc_lesson_freq=allocfreq
      sa.lessonWeek=remark
      sa.save 
      
      start=startT[0,2].to_i+1
      if start.to_s.length==1
        start="0"+start.to_s
      end
      start =start.to_s + ":30"
      startT=start
    end
    
  end
  
  end
  
  def genFiles
    file = File.new("public/files/latestSTARS.txt","r")
    subExcel=File.new("public/files/subjectDetails.xls","w")
    venExcel=File.new("public/files/venueDetails.xls","w")
    grpExcel=File.new("public/files/lessonGroupDetails.xls","w")
    
    tab="\t"
    cr="\n"
    
    subExcel.puts "SubjectCode" + tab + "SubjectName" + tab + "YearOfStudy"+tab+"discipline"+tab+"acad_unit"+tab+"cohort size"+tab+"Remark"+cr
    venExcel.puts "venueName"+tab+"capacity"+tab+"remarks"+cr
    grpExcel.puts "GroupIndex"+tab+"groupSize"+cr
    
    x=0
    entries = Array.new
    while(line=file.gets)
      if line.strip!=""
        entries[x]=line.strip
        x +=1
      end
    end
    file.close
    entries.sort
    
    first=true
    k=0
    scode=Array.new
    scode2=Array.new
    grp=Array.new
    vn =Array.new
    vn[0]="TR7"+tab+"35"
    vn[1]="TR8"+tab+"35"
    vn[2]="TR9"+tab+"35"
    vn[3]="TR10"+tab+"35"
    vn[4]="TR11"+tab+"35"
    vn[5]="TR12"+tab+"35"
    vn[6]="TR13"+tab+"35"
    vn[7]="TR14"+tab+"35"
    vn[8]="TR15"+tab+"35"
    vn[9]="TR16"+tab+"35"
    vn[10]="TR17"+tab+"35"
    vn[11]="TR18"+tab+"35"
    vn[12]="TR19"+tab+"35"
    vn[13]="TR20"+tab+"35"
    vn[14]="TR21"+tab+"35"
    vn[15]="TR22"+tab+"35"
    vn[16]="TR23"+tab+"35"
    vn[17]="TR24"+tab+"35"
    vn[18]="TR26"+tab+"35"
    vn[19]="TR39"+tab+"35"
    vn[20]="TR41"+tab+"35"
    vn[21]="TR49"+tab+"35"
    vn[22]="TR50"+tab+"35"
     
    0.upto(entries.length-1) do |y|
      
      theData=entries[y]
      subcode=theData[5,6].strip
      groupIndex=theData[14,5].strip
      type=theData[11,3].strip
      venue=theData[31,6].strip
      
      if venue[0,2]=="TR"
        vcap=35
      elsif venue[0,2]=="LT"
        vcap=120
      else
        vcap=35
      end
      
      if subcode[0,3]=="CPE"
        sdis="CE"
        syr=subcode[3,1]
      elsif subcode[0,3] =="CSC"
        sdis="CS"
        syr=subcode[3,1]
      elsif subcode[0,2] =="SC"
        sdis="SC"
        syr=subcode[2,1]
      else
        sdis="SCE"
        syr=""
      end
      
      if type=="LEC"
        grpsize=120
      elsif type=="TUT"
        grpsize=35
      else
        grpsize=35
      end
      
      grp_exist=false
      0.upto(grp.length-1) do |gl|
        temp_arr=Array.new
        temp_arr=grp[gl].split("\t")
        if temp_arr[0]==groupIndex
         grp_exist=true
         break
       end
      end
      
      if grp_exist==false
        grp[grp.length]= groupIndex + tab + grpsize.to_s
      end
      
      scode_exist=false
      
      0.upto(scode.length-1) do |p| 
       if scode[p]==subcode 
         scode_exist=true
       end
      end
      
      if scode_exist==false 
        
        scode[scode.length]=subcode
        scode2[scode2.length]=subcode+tab+ReferenceSubjects.find(subcode).subjectName+tab+ReferenceSubjects.find(subcode).yearOfStudy+tab+ReferenceSubjects.find(subcode).discipline+tab+ReferenceSubjects.find(subcode).acad_unit.to_s+tab+ReferenceSubjects.find(subcode).cohort_size.to_s+tab+ReferenceSubjects.find(subcode).remarks
      end
      
      venue_exist=false
      
      0.upto(vn.length-1) do |vl|
        temp_arr=Array.new
        temp_arr=vn[vl].split("\t")
        if temp_arr[0]==venue
         venue_exist=true
         break
       end
      end
      
      if venue_exist==false
        vn[vn.length]= venue+tab+vcap.to_s
      end
       
     end
    
    data=""
    0.upto(scode2.length-1) do |s|
      data=data+scode2[s]+cr
    end   
    
    vn=vn.sort
    dataB=""    
    0.upto(vn.length-1) do |w|
      dataB=dataB+vn[w]+cr
    end
    
    grp=grp.sort
    dataC=""
    0.upto(grp.length-1) do |z|
      dataC=dataC+grp[z]+cr
    end
     
    subExcel.puts data
    venExcel.puts dataB
    grpExcel.puts dataC
    subExcel.close
    venExcel.close
    grpExcel.close   
  end
  

 
 def update_stars
    if session[:user]==nil
      redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
    end
 end
 
  def process_update
    post = Files.save(@params["starsFile"])
    self.genFiles()
  end
  
  def update
    SlotAllocation.delete_all
    ActiveRecord::Base.connection.execute("Alter table slot_allocations AUTO_INCREMENT=1") 
        
    contents=""
    subExcel=File.new("public/files/subjectDetails.xls","r")
    contents=subExcel.read
    subExcel.close
    
    arr = Array.new    
    sub= Array.new
    arr= contents.split("\n")
    
    1.upto(arr.length-1) do |h|
      sub[h] = arr[h].split("\t")
    end
    
    1.upto(sub.length-1) do |h|
      sub_exist=Subject.find_by_sql("Select * from subjects where subjectCode='#{sub[h][0].strip}'")
      if sub_exist.length==0
        subject = Subject.new
        subject.id=sub[h][0].strip
        subject.subjectName=sub[h][1].strip
        subject.yearOfStudy=sub[h][2].strip
        subject.discipline=sub[h][3].strip
        subject.acad_unit=sub[h][4].strip
        subject.cohort_size=sub[h][5].strip
        subject.remarks=sub[h][6]
        if subject.remarks==nil
          subject.remarks=""
        end      
        subject.save 
      end
    end
    
    contents=""
    venExcel=File.new("public/files/venueDetails.xls","r")
    contents=venExcel.read
    venExcel.close
    
    ven= Array.new
    arr= contents.split("\n")
    
    1.upto(arr.length-1) do |h|
      ven[h] = arr[h].split("\t")
    end
    
    1.upto(ven.length-1) do |h|
      vname=ven[h][0].strip
      vcap=ven[h][1].strip
      vrem=ven[h][2]
      
      ven_exist=Venue.find_by_sql("Select * from venues where venueName='#{vname}'")
      if ven_exist.length==0
        if vrem==nil
          vrem=""
        else
          vrem=ven[h][2].strip
        end
         
        if vname[0,2]=="TR" 
          vtype="Tut"
        elsif vname[0,2]=="LT" 
          vtype="Lec"
        else
          vtype="Lab"
        end
        
        venue=Venue.new
        venue.id=vname
        venue.venueType=vtype
        venue.capacity=vcap
        venue.remarks=vrem
        venue.save
      end      
    end
    
    contents=""
    lessonGrpExcel=File.new("public/files/lessonGroupDetails.xls","r")
    contents=lessonGrpExcel.read
    lessonGrpExcel.close
    
    arr.clear  
    les_grp= Array.new
    arr= contents.split("\n")
    
    1.upto(arr.length-1) do |h|
      les_grp[h] = arr[h].split("\t")
    end
    
    1.upto(les_grp.length-1) do |h|      
      group_index=les_grp[h][0].strip
      group_size=les_grp[h][1].strip
      lg_exist=LessonGroup.find_by_sql("Select * from lesson_groups where groupIndex='#{group_index}'")
      
      if lg_exist.length==0      
        leng=group_index.length
        gr=group_index[leng-2,2]
        if gr.to_i==0
          group_prefix=group_index[0,leng-1]
          group_no=group_index[leng-1,1]
          if group_no.to_i==0
            group_prefix=group_index
            group_no=0
          end
        else
          group_prefix=group_index[0,leng-2]
          group_no=gr
        end
        
        grp=LessonGroup.new
        grp.groupIndex=group_index
        grp.groupPrefix=group_prefix
        grp.groupNo=group_no
        grp.groupSize=group_size
        grp.save      
      end
    end
    
    file = File.new("public/files/latestSTARS.txt","r")
    entries = Array.new
    x=0
    while(line=file.gets)
      if line.strip!=""
        entries[x]=line.strip
        x +=1
      end
    end
    file.close
    entries.sort
    
    0.upto(entries.length-1) do |y|
      
      theData=entries[y]
      subcode=theData[5,6].strip
      groupIndex=theData[14,5].strip
      type=theData[11,3].strip
      venue=theData[31,20].strip
      day=theData[19,2].strip
      startT=theData[21,5].strip
      endT=theData[26,5].strip
      
      if type=="LEC"
        nof=3
        posVenues=venue
      elsif type=="TUT"
        posVenues="TR7,TR8,TR9,TR10,TR11,TR12,TR13,TR14,TR15,TR16,TR17,TR18,TR19,TR20,TR21,TR22,TR23,TR24,TR26,TR39,TR41,TR49,TR50" 
        if posVenues.include?(venue)==false
          posVenues = venue + "," + posVenues
        end
        nof=1
      else
          posVenues=venue
          nof=1
      end
    
      if day=="M" 
        day="Monday"
      elsif day=="T"
        day="Tuesday"
      elsif day=="W"
        day="Wednesday"
      elsif day=="TH"
        day="Thursday"
      elsif day=="F"
        day="Friday"
      else
        day="Saturday"
      end
    
      remark=""
      1.upto(13) do|w|
        if theData[50+w,1]!="N"
          remark+=w.to_s+","
        end
      end
    
      remark=remark[0,remark.length-1]
      weeks="1,2,3,4,5,6,7,8,9,10,11,12,13"
      wklen=weeks.length
      rmlen=remark.length
    
      if rmlen!=wklen
        allocfreq="Weekly"
        if rmlen==13
          if remark[0,1].to_s!="2" 
            allocfreq="Odd"
          else
            allocfreq="Even"
          end
        elsif rmlen==15
          allocfreq="Odd"
        end
        freq="Altern"
      else
        freq="Weekly"
        allocfreq="Weekly"
      end
    
      query=Lesson.find_by_sql("Select lessonId from lessons where subjectCode='#{subcode}' And lessonType='#{type}'")
      if query[0]==nil
        lesson=Lesson.new
        lesson.subjectCode=subcode
        lesson.lessonType=type
        lesson.noOfLesson=nof
        lesson.frequency=freq
        lesson.lessonGroupsAssigned=groupIndex
        lesson.possibleVenues=posVenues
        lesson.save
        query=Lesson.find_by_sql("Select lessonId from lessons where subjectCode='#{subcode}' And lessonType='#{type}'")
        lessonid=query[0].lessonId
      else
        lessonid=query[0].lessonId
        if Lesson.find(lessonid).possibleVenues.include?(posVenues)==false
          posVen2=Lesson.find(lessonid).possibleVenues+","+venue
          Lesson.find(lessonid).update_attribute :possibleVenues, posVen2
        end
        if Lesson.find(lessonid).lessonGroupsAssigned.include?(groupIndex)==false
          new_lg_assigned=Lesson.find(lessonid).lessonGroupsAssigned+","+groupIndex
          Lesson.find(lessonid).update_attribute :lessonGroupsAssigned, new_lg_assigned
        end    
      end
    
      groupid=LessonGroup.find(:first,:conditions=>"groupIndex = '#{groupIndex}'").groupId
    
      query=StaffAssignment.find_by_sql("Select assignId from staff_assignments where groupId =#{groupid} And lessonId=#{lessonid}")
      if query[0]==nil
        sta=StaffAssignment.new
        sta.groupId=groupid
        sta.lessonId=lessonid
        sta.staffId=0
        sta.teachLessonWeek=remark
        sta.save
      end
        
      while(startT<endT)
        query=TimeSlot.find_by_sql("Select timeSlotId from time_slots where startTime='#{startT}' And dayOfWeek='#{day}'")
        timeid=query[0].timeSlotId
        sa=SlotAllocation.new
        sa.lessonId=lessonid
        sa.groupId=groupid
        sa.venueName=venue
        sa.timeSlotId=timeid
        sa.alloc_lesson_freq=allocfreq
        sa.lessonWeek=remark
        sa.save 
        
        start=startT[0,2].to_i+1
        if start.to_s.length==1
          start="0"+start.to_s
        end
        start =start.to_s + ":30"
        startT=start
      end
      
    end
    
  end
  
end
