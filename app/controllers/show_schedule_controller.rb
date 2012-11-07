class ShowScheduleController < ApplicationController
  layout 'standard' 
  
  
  def by_subjects
    if session[:user]==nil
      redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
    else
      @subjects=Subject.find(:all,:order=>"subjectCode")       
      @subLists=SubjectList.find_by_sql("Select Distinct subjectListName from subject_lists order by subjectListName")
    end
  end
  
  def intercept_subject
    
    @ssd=params[:scheduleSubjectDDM]
    @maxday=params[:maxDay]
    @maxtimeslot=params[:maxTimeSlot]
    
    session[:maxDay]=@maxday
    session[:maxTimeSlot]=@maxtimeslot
    
    @dday=Array.new
    @dday[1]="Monday"
    @dday[2]="Tuesday"
    @dday[3]="Wednesday"
    @dday[4]="Thursday"
    @dday[5]="Friday"
    if @maxday=="6"
      @dday[6]="Saturday"
    end
     
    if @maxtimeslot == "1730"
      @rowspanNo=10
      @tInc=4
    else
      @rowspanNo=14
      @tInc=0
    end 
    
    @slotAlloc=Array.new
    0.upto(@ssd.length-1) do |s|
      @slotAlloc[s]=SlotAllocation.find_by_sql("SELECT SA.timeSlotId as timeid, SA.groupId, concat(LG.groupIndex,'-',SA.venueName,'(',SA.alloc_lesson_freq,')','\n') as details, SA.allocationId as allocId, L.lessonType as lessonType FROM slot_allocations SA,lessons L, lesson_groups LG where L.subjectCode='#{@ssd[s]}' and SA.lessonId=L.lessonId and SA.groupId=LG.groupId")
    end  
    
  end
  
  def by_staffs    
    if session[:user]==nil
      redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
    else
      @staff_list=Staff.find(:all, :conditions=>"staffId!=0",:order=>"staffName")
    end    
  end
  
  def intercept_staff
    
    @ssd=params[:scheduleStaffDDM]
    @maxday=params[:maxDay]
    @maxtimeslot=params[:maxTimeSlot]
    
    session[:maxDay]=@maxday
    session[:maxTimeSlot]=@maxtimeslot
    
    @dday=Array.new
    @dday[1]="Monday"
    @dday[2]="Tuesday"
    @dday[3]="Wednesday"
    @dday[4]="Thursday"
    @dday[5]="Friday"
    if @maxday=="6"
      @dday[6]="Saturday"
    end
     
    if @maxtimeslot == "1730"
      @rowspanNo=10
      @tInc=4
    else
      @rowspanNo=14
      @tInc=0
    end 
    
    @slotAlloc=Array.new
    0.upto(@ssd.length-1) do |s|
      @slotAlloc[s]=SlotAllocation.find_by_sql("SELECT SA.timeSlotId as timeid, concat(L.subjectCode,'-',LG.groupIndex,'-',L.lessonType,'-',SA.venueName,' (',SA.alloc_lesson_freq,')') as details, L.lessonType as lessonType FROM staffs S, staff_assignments STA, slot_allocations SA,lessons L, lesson_groups LG where S.staffId='#{@ssd[s]}' and SA.lessonId=L.lessonId and SA.groupId=LG.groupId and SA.lessonId=STA.lessonId and SA.groupId=STA.groupId and STA.staffId=S.staffId")
    end  
    
  end
  
  def by_venues   
    if session[:user]==nil
      redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
    else
      @venue_list=Venue.find(:all,:order=>:venueName,:conditions=>"venueName!='Not Assigned'")
    end    
  end
  
  def intercept_venue
    
    @ssd=params[:scheduleVenueDDM]
    @maxday=params[:maxDay]
    @maxtimeslot=params[:maxTimeSlot]
    
    session[:maxDay]=@maxday
    session[:maxTimeSlot]=@maxtimeslot
    
    @dday=Array.new
    @dday[1]="Monday"
    @dday[2]="Tuesday"
    @dday[3]="Wednesday"
    @dday[4]="Thursday"
    @dday[5]="Friday"
    if @maxday=="6"
      @dday[6]="Saturday"
    end
     
    if @maxtimeslot == "1730"
      @rowspanNo=10
      @tInc=4
    else
      @rowspanNo=14
      @tInc=0
    end 
    
    @slotAlloc=Array.new
    0.upto(@ssd.length-1) do |s|
      @slotAlloc[s]=SlotAllocation.find_by_sql("SELECT SA.timeSlotId as timeid, concat(LG.groupIndex,'-',L.subjectCode,' (',SA.alloc_lesson_freq,')',' -',L.lessonType) as details, L.lessonType as lessonType FROM slot_allocations SA,lessons L, lesson_groups LG where SA.venueName='#{@ssd[s]}' and SA.lessonId=L.lessonId and SA.groupId=LG.groupId ")
    end  
    
  end
  
  def by_groups
    if session[:user]==nil
      redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
    else
      @grp_list=LessonGroup.find(:all,:order=>:groupIndex)
    end    
  end
  
  def intercept_group
    
    @ssd=params[:scheduleGroupDDM]
    @maxday=params[:maxDay]
    @maxtimeslot=params[:maxTimeSlot]
    
    session[:maxDay]=@maxday
    session[:maxTimeSlot]=@maxtimeslot
    
    @dday=Array.new
    @dday[1]="Monday"
    @dday[2]="Tuesday"
    @dday[3]="Wednesday"
    @dday[4]="Thursday"
    @dday[5]="Friday"
    if @maxday=="6"
      @dday[6]="Saturday"
    end
     
    if @maxtimeslot == "1730"
      @rowspanNo=10
      @tInc=4
    else
      @rowspanNo=14
      @tInc=0
    end 
    
    @slotAlloc=Array.new
    0.upto(@ssd.length-1) do |s|
      @slotAlloc[s]=SlotAllocation.find_by_sql("SELECT SA.timeSlotId as timeid, concat(L.subjectCode,'-',SA.venueName,' -',L.lessonType,' (',SA.alloc_lesson_freq,')') as details, L.lessonType as lessonType FROM slot_allocations SA,lessons L, lesson_groups LG where LG.groupIndex='#{@ssd[s]}' and SA.lessonId=L.lessonId and SA.groupId=LG.groupId")
    end  
    
  end
  
  
  def export_excel
    
    content_list=params[:subList]
    stype=params[:stype]
    maxday=params[:maxDay]
    maxtimeslot=params[:maxTimeSlot]
    
    if maxday!=nil 
      session[:maxDay]=maxday
    end
    if maxtimeslot!=nil
      session[:maxTimeSlot]=maxtimeslot
    end
    
    
    dday=Array.new
    dday[1]="Monday"
    dday[2]="Tuesday"
    dday[3]="Wednesday"
    dday[4]="Thursday"
    dday[5]="Friday"
    if session[:maxDay]=="6"
      dday[6]="Saturday"
    end
     
    if session[:maxTimeSlot] == "1730"
      rowspanNo=10
      tInc=4
    else
      rowspanNo=14
      tInc=0
    end 
    
    list_arr=Array.new
    list_arr=content_list.split("-")
    slotAlloc=Array.new
    0.upto(list_arr.length-1) do |s|
      if stype=="sub"
        slotAlloc[s]=SlotAllocation.find_by_sql("SELECT SA.timeSlotId as timeid,concat(LG.groupIndex,'-',SA.venueName,'(',SA.alloc_lesson_freq,')') as details FROM slot_allocations SA,lessons L, lesson_groups LG where L.subjectCode='#{list_arr[s]}' and SA.lessonId=L.lessonId and SA.groupId=LG.groupId")
      elsif stype=="staff"
        slotAlloc[s]=SlotAllocation.find_by_sql("SELECT SA.timeSlotId as timeid, concat(LG.groupIndex,'-',SA.venueName,'-',L.lessonType,'(',SA.alloc_lesson_freq,')','-',S.staffName) as details FROM staffs S, staff_assignments STA, slot_allocations SA,lessons L, lesson_groups LG where L.subjectCode='#{list_arr[s]}'  and SA.lessonId=L.lessonId and SA.groupId=LG.groupId and SA.lessonId=STA.lessonId and SA.groupId=STA.groupId and STA.staffId=S.staffId")
      elsif stype=="by_staff"
        slotAlloc[s]=SlotAllocation.find_by_sql("SELECT SA.timeSlotId as timeid, concat(SA.venueName,'-',LG.groupIndex,'-',L.subjectCode,' (',SA.alloc_lesson_freq,')',' -',L.lessonType) as details FROM staffs S, staff_assignments STA, slot_allocations SA,lessons L, lesson_groups LG where S.staffId='#{list_arr[s]}' and SA.lessonId=L.lessonId and SA.groupId=LG.groupId and SA.lessonId=STA.lessonId and SA.groupId=STA.groupId and STA.staffId=S.staffId")
      elsif stype=="by_group"
        slotAlloc[s]=SlotAllocation.find_by_sql("SELECT SA.timeSlotId as timeid, concat(L.subjectCode,'-',SA.venueName,' -',L.lessonType,' (',SA.alloc_lesson_freq,')') as details FROM slot_allocations SA,lessons L, lesson_groups LG where LG.groupIndex='#{list_arr[s]}' and SA.lessonId=L.lessonId and SA.groupId=LG.groupId")
      elsif stype=="by_venue"
        slotAlloc[s]=SlotAllocation.find_by_sql("SELECT SA.timeSlotId as timeid, concat(LG.groupIndex,'-',L.subjectCode,' (',SA.alloc_lesson_freq,')',' -',L.lessonType) as details FROM slot_allocations SA,lessons L, lesson_groups LG where SA.venueName='#{list_arr[s]}' and SA.lessonId=L.lessonId and SA.groupId=LG.groupId ")
      end 
    end  
    
    showTT=File.new("public/files/showTT.xls","w")
    
    tab="\t"
    cr="\n"
    
    
    sub=""
    if stype=="by_staff"
      0.upto(list_arr.length-1) do |sl|
        sub+= tab + Staff.find(list_arr[sl]).staffName 
      end
    else
      0.upto(list_arr.length-1) do |sl|
        sub+= tab + list_arr[sl] 
      end
    end
    
    showTT.puts "DAY" + tab + "TIME" + sub + tab + "TIME"+ cr
    tsid=1
    1.upto(session[:maxDay].to_i) do |day|
      
        row=""
        row=dday[day]+ tab + "830" + tab
        0.upto(list_arr.length-1) do |sl|
          0.upto(slotAlloc[sl].length-1) do |sa|
            if slotAlloc[sl][sa].timeid.to_i==tsid.to_i           
              row +=slotAlloc[sl][sa].details + " ," 
            end            
          end
          if row[row.length-1,row.length]==","
            row=row[0,row.length-1]
          end
          
          row+=tab
        end
        row+="830"+cr
        showTT.puts row
        tsid+=1
         row=""
        930.step(session[:maxTimeSlot].to_i,100) do |time_index|
          row= tab + time_index.to_s + tab
          0.upto(list_arr.length-1) do |sl|
            0.upto(slotAlloc[sl].length-1) do |sa|
              if slotAlloc[sl][sa].timeid.to_i==tsid.to_i
                row += slotAlloc[sl][sa].details + " ,"
              end            
            end
            if row[row.length-1,row.length]==","
              row=row[0,row.length-1]
            end
            row+=tab
          end
          row+=time_index.to_s+cr
          showTT.puts row
          tsid+=1
        end
        tsid+=tInc
    end
    
    
    showTT.close
    
    render :nothing=>true
  end  
  
  def export_done
    render :layout=>false
  end  
  
end
