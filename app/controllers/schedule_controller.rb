class ScheduleController < ApplicationController
  layout 'standard' 
  def schedule
    if session[:user]==nil
      redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
    else
      @subjects=Subject.find(:all,:order=>"subjectCode")       
      @subLists=SubjectList.find_by_sql("Select Distinct subjectListName from subject_lists order by subjectListName")
    end
  end
  
  def schedule_staff
    if session[:user]==nil
      redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
    else
      @subjects=Subject.find(:all,:order=>"subjectCode")       
      @subLists=SubjectList.find_by_sql("Select Distinct subjectListName from subject_lists order by subjectListName")
    end
  end
  
  def intercept
    session[:count]=0
    
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
    
    @dropOnListName=Array.new
    @slotAlloc=Array.new
    0.upto(@ssd.length-1) do |s|
      @dropOnListName[s]=""
      @slotAlloc[s]=SlotAllocation.find_by_sql("SELECT SA.timeSlotId as timeid, SA.groupId, concat(LG.groupIndex,'-',SA.venueName,'(',SA.alloc_lesson_freq,')','\n') as details, SA.allocationId as allocId, L.lessonType as lessonType FROM slot_allocations SA,lessons L, lesson_groups LG where L.subjectCode='#{@ssd[s]}' and SA.lessonId=L.lessonId and SA.groupId=LG.groupId")
    end  
    
  end
  
  def schedule_staff
    if session[:user]==nil
      redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
    else
      @subjects=Subject.find(:all,:order=>"subjectCode")       
      @subLists=SubjectList.find_by_sql("Select Distinct subjectListName from subject_lists order by subjectListName")
    end
  end
  
  def intercept_staff
    
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
      @slotAlloc[s]=SlotAllocation.find_by_sql("SELECT SA.timeSlotId as timeid, STA.staffId, concat(LG.groupIndex,'-',SA.venueName,'-',L.lessonType,'(',SA.alloc_lesson_freq,')','-',S.staffName) as details, SA.allocationId as allocId, L.lessonType as lessonType FROM staffs S, staff_assignments STA, slot_allocations SA,lessons L, lesson_groups LG where L.subjectCode='#{@ssd[s]}' and SA.lessonId=L.lessonId and SA.groupId=LG.groupId and SA.lessonId=STA.lessonId and SA.groupId=STA.groupId and STA.staffId=S.staffId")
    end  
    
  end
  
  def change_schedule
    
    if session[:count]==0 
      session[:count]=1
      @status="false"
      session[:oldtsid]=params[:timeId]
    else
      
      new_tsid=params[:timeId]      
      slot_allocid=session[:ditem]
      
      if SlotAllocation.find(slot_allocid).timeSlotId.to_i==new_tsid.to_i
        temp=new_tsid
        new_tsid=session[:oldtsid]
        session[:oldtsid]=temp
      end
      
      @scode=params[:sub]
      @time_id=session[:oldtsid]
      @changeto_timeid =new_tsid
      grp_index=LessonGroup.find(SlotAllocation.find(slot_allocid).groupId).groupIndex
      duplicate_query=SlotAllocation.find_by_sql("Select SA.allocationId from slot_allocations SA, lesson_groups LG, lessons L where L.subjectCode='#{@scode}' and SA.lessonId=L.lessonId and SA.groupId=LG.groupId and LG.groupIndex='#{grp_index}' and SA.timeSlotId=#{new_tsid}")
      
      if duplicate_query.length>0
        @status="duplicate" 
        @clash_info="duplicate"  
      else
        
        if SlotAllocation.find(slot_allocid).alloc_lesson_freq=="Weekly"
          clash_query=SlotAllocation.find(:all,:conditions=>"venueName='#{SlotAllocation.find(slot_allocid).venueName}' and timeSlotId='#{new_tsid}'")
        else
          clash_query=SlotAllocation.find(:all,:conditions=>"venueName='#{SlotAllocation.find(slot_allocid).venueName}' and timeSlotId='#{new_tsid}' and (alloc_lesson_freq='#{SlotAllocation.find(slot_allocid).alloc_lesson_freq}' Or alloc_lesson_freq='Weekly')")
        end
        
        if clash_query.length>0
          lesson_type=Lesson.find(SlotAllocation.find(slot_allocid).lessonId).lessonType
          shared_query=SharedSubjectCode.find(:all, :conditions=>"sharedType like '%#{lesson_type}%' and sharedSubjectCodes like '%#{@scode}%'")
          if shared_query.length==1
            shared_sub_codes=shared_query[0].sharedSubjectCodes
            0.upto(clash_query.length-1) do |cq|
              if shared_sub_codes.include?(Lesson.find(clash_query[cq].lessonId).subjectCode.to_s)==false
                @status="clash"
                @clash_info=Lesson.find(clash_query[cq].lessonId).subjectCode+" "+Subject.find(Lesson.find(clash_query[cq].lessonId).subjectCode).subjectName+" ("+Lesson.find(clash_query[cq].lessonId).lessonType+") -"+LessonGroup.find(clash_query[cq].groupId).groupIndex
                break
              end            
            end
          else
            @status="clash"
            @clash_info=Lesson.find(clash_query[0].lessonId).subjectCode+" "+Subject.find(Lesson.find(clash_query[0].lessonId).subjectCode).subjectName+" ("+Lesson.find(clash_query[0].lessonId).lessonType+") -"+LessonGroup.find(clash_query[0].groupId).groupIndex
          end
        end
        
        if @status!="clash"
          @status="true"
          SlotAllocation.find(slot_allocid).update_attribute :timeSlotId,new_tsid
        end
        
      end
      session[:count]=0
    end
    
    render :layout=>false
  end
  
  def confirm_schedule_change
    new_tsid=params[:newTsid]
    slot_allocid=session[:ditem]
    SlotAllocation.find(slot_allocid).update_attribute :timeSlotId,new_tsid
    
    render :nothing=>true
  end
  
  
  def shared_code_change
    slot_id=session[:ditem]
    lesson_id=SlotAllocation.find(slot_id).lessonId
    lesson_type=Lesson.find(lesson_id).lessonType
    scode=params[:scode]
    time_id=params[:oldTsid]
    changeto_timeid=params[:newTsid]
    @have_shared_sub=false
    shared_query=SharedSubjectCode.find(:all, :conditions=>"sharedType like '%#{lesson_type}%' and sharedSubjectCodes like '%#{scode}%'")
    
    if shared_query.length==1
      @have_shared_sub=true
      scode_arr=Array.new
      scode_arr=shared_query[0].sharedSubjectCodes.split(",")
      
      @shared_sub_details=""
      
      0.upto(scode_arr.length-1) do |sc|
        
        if scode_arr[sc]!=scode
          shared_lesson_id=Lesson.find(:first,:conditions=>"lessonType='#{lesson_type}' and subjectCode='#{scode_arr[sc]}'").lessonId
          entry=SlotAllocation.find(:all,:conditions=>"lessonId='#{shared_lesson_id}' and timeSlotId='#{time_id}'")
          if entry.length>0
            entry[0].update_attribute :timeSlotId,changeto_timeid
            @shared_sub_details+=":"+scode_arr[sc]+":"+time_id.to_s+":"+changeto_timeid.to_s+"-"
          end
        end        
        
      end
      
    end
    
    render :layout=>false
    
  end
  
  def list_all_lessons
    scode=params[:scode]
    old_tsid=params[:oldTsid]
    new_tsid=params[:newTsid] 
    
    query_details=SlotAllocation.find_by_sql("SELECT SA.allocationId as allocId, L.lessonType, concat(LG.groupIndex,'-',SA.venueName,'(',SA.alloc_lesson_freq,')') as details, SA.groupId FROM slot_allocations SA, lessons L, lesson_groups LG where L.subjectCode='#{scode}' and SA.timeSlotId=#{old_tsid} and SA.lessonId=L.lessonId and SA.groupId=LG.groupId group by allocId")
    @all_old_class=Array.new
    0.upto(query_details.length-1) do |qd|
      temp_string=query_details[qd].allocId.to_s+":"+query_details[qd].lessonType+":"+query_details[qd].details+":"+query_details[qd].groupId.to_s+"->"
      @all_old_class[qd]=temp_string
    end
    
    query_details=SlotAllocation.find_by_sql("SELECT SA.allocationId as allocId, L.lessonType, concat(LG.groupIndex,'-',SA.venueName,'(',SA.alloc_lesson_freq,')') as details, SA.groupId FROM slot_allocations SA, lessons L, lesson_groups LG where L.subjectCode='#{scode}' and SA.timeSlotId=#{new_tsid} and SA.lessonId=L.lessonId and SA.groupId=LG.groupId group by allocId")
    @all_new_class=Array.new
    0.upto(query_details.length-1) do |qd|
      temp_string=query_details[qd].allocId.to_s+":"+query_details[qd].lessonType+":"+query_details[qd].details+":"+query_details[qd].groupId.to_s+"->"
      @all_new_class[qd]=temp_string
    end
    
    render :layout=>false
  end
  
  
  def create_session
    session[:ditem]=params[:slotid]
    session[:count]=0
    render :nothing=>true    
  end
  
  def schedule_time_slot
    @scode=params[:scode]
    session[:tsid]=params[:tsid]
    tsid=session[:tsid]
    
    query=Subject.find(:first,:conditions=>"subjectCode='#{@scode}'")
    @au=query.acad_unit
    
    @slot_details=SlotAllocation.find_by_sql("SELECT SA.allocationId as allocId, L.lessonType,LG.groupIndex,SA.venueName, SA.groupId, SA.alloc_lesson_freq as freq, STA.teachLessonWeek, ST.staffName, ST.staffId,TS.startTime, TS.endTime, TS.dayOfWeek FROM slot_allocations SA,lessons L, lesson_groups LG, time_slots TS, staffs ST, staff_assignments STA where L.subjectCode='#{@scode}' and SA.timeSlotId=#{tsid} and SA.lessonId=L.lessonId and SA.groupId=LG.groupId and ST.staffId=STA.staffId and STA.groupId=SA.groupId group by allocId")
    @day_list=session[:maxDay]
    @time_list=session[:maxTimeSlot]
    @startT=TimeSlot.find(tsid).startTime
    @endT=TimeSlot.find(tsid).endTime
    @day_choose=TimeSlot.find(tsid).dayOfWeek
    
    case @day_choose
      when "Monday"
        @sel_index_day=0
      when "Tuesday"
        @sel_index_day=1
      when "Wednesday"
        @sel_index_day=2
      when "Thursday"
        @sel_index_day=3
      when "Friday"
        @sel_index_day=4
      when "Saturday"
        @sel_index_day=5
		end
   
    ind=0
   830.step(@time_list.to_i,100) do |t| 
    if t.to_s.length==3
      st="0"+t.to_s[0,1]+":"+t.to_s[1,2]+":00"
        else
      st=t.to_s[0,2]+":"+t.to_s[2,2]+":00"
    end
    if @startT.to_s.include?(st)
      @sel_index_time=ind
      ind+=1
      break
    else
      ind+=1
    end
  end
  
  
    @lesson_list=Lesson.find_by_sql("SELECT lessonType, frequency, possibleVenues FROM lessons where subjectCode='#{@scode}' group by lessonType")
    @group_list=Lesson.find(:all, :conditions=>"subjectCode='#{@scode}'")
    
    @venue_query=SlotAllocation.find_by_sql("SELECT allocationId,venueName,alloc_lesson_freq as allocFreq FROM slot_allocations where timeSlotId=#{tsid}")
    @lesson_query=SlotAllocation.find_by_sql("SELECT L.subjectCode, L.lessonType, SA.venueName, SA.alloc_lesson_freq as allocFreq FROM lessons L, slot_allocations SA where L.subjectCode='#{@scode}' and L.lessonId=SA.lessonId group by lessonType")
    
    @lecturer_list = Staff.find_by_sql("SELECT staffId, staffName, subjectAssigned FROM staffs where (subjectAssigned like '%#{@scode}%' or subjectAssigned ='') order by staffName")
    @exist_lecturer_list=StaffAssignment.find_by_sql("SELECT STA.staffId, ST.staffName, L.lessonType, LG.groupIndex FROM lessons L, staff_assignments STA, lesson_groups LG, staffs ST where L.subjectCode='#{@scode}' and L.lessonId=STA.lessonId and STA.groupId=LG.groupId and STA.staffId=ST.staffId")
    
    render :layout=>false
  
end
  
  def check_venue_clash
    day_sel=params[:daySel]
    st_sel=params[:stSel]
    et_sel=params[:etSel]
    ven_sel=params[:venSel]
    freq_sel=params[:freqSel]
    @status="Unoccupied"
    check=true
    
    @duration=et_sel[0,2].to_i-st_sel[0,2].to_i
    
    if @duration <=0
      check=false
      @status="Failed"
    end
    
    if check
    new_tsid=TimeSlot.find(:first,:select=>:timeSlotId,:conditions=>"dayOfWeek='#{day_sel}' and startTime='#{st_sel}'").timeSlotId
   
    1.upto(@duration) do |d|
      if freq_sel=="Weekly"
        venue_clash_query=SlotAllocation.find_by_sql("SELECT * FROM slot_allocations where timeSlotId=#{new_tsid} and venueName='#{ven_sel}'")
      else
        venue_clash_query=SlotAllocation.find_by_sql("SELECT * FROM slot_allocations where timeSlotId=#{new_tsid} and venueName='#{ven_sel}' and (alloc_lesson_freq='#{freq_sel}' Or alloc_lesson_freq='Weekly')")
      end
      
      if venue_clash_query.length>0
        @status="Occupied"
        break
      else
        @status="Unoccupied"
      end
      
      new_tsid+=1
    end
  end
  
    render :layout=>false
  end
  
  def assign_lecturer
    scode=params[:subcode]
    class_type=params[:ctSel]
    grp_index=params[:grpIndex]
    staff_id=params[:staffId]
    teach_week_list=params[:teachWeekList]
        
    lesson_id=Lesson.find(:first,:select=>:lessonId, :conditions=>"subjectCode='#{scode}' and lessonType='#{class_type}'").lessonId
    grp_id=LessonGroup.find(:first,:select=>:groupId,:conditions=>"groupIndex='#{grp_index}'").groupId
    
    entry=StaffAssignment.find(:first,:conditions=>"groupId =#{grp_id} and lessonId=#{lesson_id}")
    
    if entry.staffId==0
      entry.update_attribute :staffId,staff_id
      entry.update_attribute :teachLessonWeek, teach_week_list
    else
      sta=StaffAssignment.new
      sta.groupId=grp_id
      sta.lessonId=lesson_id
      sta.staffId=staff_id
      sta.teachLessonWeek=teach_week_list
      sta.save
    end
    
    @new_list=StaffAssignment.find_by_sql("Select STA.staffId, ST.staffName from staff_assignments STA, staffs ST where STA.groupId=#{grp_id} and STA.lessonId=#{lesson_id} and STA.staffId=ST.staffId")
    
    render :layout=>false
  end
  
  def unassign_lecturer
    scode=params[:subcode]
    class_type=params[:ctSel]
    grp_index=params[:grpIndex]
    staff_id=params[:staffId]
    freq_sel=params[:freqSel]
    
    lesson_id=Lesson.find(:first,:select=>:lessonId, :conditions=>"subjectCode='#{scode}' and lessonType='#{class_type}'").lessonId
    grp_id=LessonGroup.find(:first,:select=>:groupId,:conditions=>"groupIndex='#{grp_index}'").groupId
    assign_id=StaffAssignment.find(:first,:select=>:assignId,:conditions=>"groupId =#{grp_id} and lessonId=#{lesson_id} and staffId=#{staff_id}").assignId
    
    
    StaffAssignment.delete(assign_id)
  
    @new_list=StaffAssignment.find_by_sql("Select STA.staffId, ST.staffName from staff_assignments STA, staffs ST where STA.groupId=#{grp_id} and STA.lessonId=#{lesson_id} and STA.staffId=ST.staffId")
    
    if @new_list.length==0
      sta=StaffAssignment.new
      sta.groupId=grp_id
      sta.lessonId=lesson_id
      sta.staffId=0
      if freq_sel=="Weekly"
        sta.teachLessonWeek="1,2,3,4,5,6,7,8,9,10,11,12,13"
      elsif freq_sel=="Odd"
        sta.teachLessonWeek="1,3,5,7,9,11,13"
      else
        sta.teachLessonWeek="2,4,6,8,10,12"
      end
      sta.save
      @new_list=StaffAssignment.find_by_sql("Select STA.staffId, ST.staffName from staff_assignments STA, staffs ST where STA.groupId=#{grp_id} and STA.lessonId=#{lesson_id} and STA.staffId=ST.staffId")
    end
    
    
     render :layout=>false
  end
  
  def list_exist_lecturer
    scode=params[:subcode]
    class_type=params[:ctSel]
    grp_index=params[:grpIndex]
    
    
    lesson_id=Lesson.find(:first,:select=>:lessonId, :conditions=>"subjectCode='#{scode}' and lessonType='#{class_type}'").lessonId
    grp_id=LessonGroup.find(:first,:select=>:groupId,:conditions=>"groupIndex='#{grp_index}'").groupId
    
    @new_list=StaffAssignment.find_by_sql("Select STA.staffId, ST.staffName from staff_assignments STA, staffs ST where STA.groupId=#{grp_id} and STA.lessonId=#{lesson_id} and STA.staffId=ST.staffId")
     render :layout=>false
   end
   
   def check_teach_week
   scode=params[:subcode]
    class_type=params[:ctSel]
    grp_index=params[:grpIndex]
    staff_id=params[:staffId]
    
    lesson_id=Lesson.find(:first,:select=>:lessonId, :conditions=>"subjectCode='#{scode}' and lessonType='#{class_type}'").lessonId
    grp_id=LessonGroup.find(:first,:select=>:groupId,:conditions=>"groupIndex='#{grp_index}'").groupId
    @teach_week_list=StaffAssignment.find(:first,:select=>:teachLessonWeek,:conditions=>"groupId =#{grp_id} and lessonId=#{lesson_id} and staffId=#{staff_id}").teachLessonWeek
    
    render :layout=>false
  end
  
  
  def process_schedule
    session[:sid]=""
    no_button=params[:noBtn]
    yes_button=params[:yesBtn]
    
    @no_button_clicked=false
    if no_button==nil
      add_clicked=params[:addBtn]
      update_clicked=params[:updateBtn]
      delete_clicked=params[:delBtn]
      
      scode=params[:subcode]
      day_sel=params[:daySel]
      st_sel=params[:stSel]
      et_sel=params[:etSel]
      duration=params[:duration]
      class_type=params[:ctSel]
      grp_index=params[:grpSel]
      ven_sel=params[:venSel]
      occ_status=params[:status]
      freq_sel=params[:freqSel]
      staff_id=params[:lecturerSel]
      teach_week=params[:teachWeekCheckbox]
      alloc_id=params[:grpList]
      
     
      if teach_week!=nil
        teach_week_list=""
        0.upto(teach_week.length-1) do |tw|
          teach_week_list +=teach_week[tw]+","
        end
        
        teach_week_list=teach_week_list[0,teach_week_list.length-1]
      else
         #yes button was clicked
        teach_week_list=params[:teachWeekList]
      end
      
      lessonWeek=""
      if freq_sel=="Weekly"
        lessonWeek="1,2,3,4,5,6,7,8,9,10,11,12,13"
      elsif freq_sel=="Odd"
        lessonWeek="1,3,5,7,9,11,13"
      else
        lessonWeek="2,4,6,8,10,12"
      end
      
      lesson_id=Lesson.find(:first,:select=>:lessonId, :conditions=>"subjectCode='#{scode}' and lessonType='#{class_type}'").lessonId
      grp_id=LessonGroup.find(:first,:select=>:groupId,:conditions=>"groupIndex='#{grp_index}'").groupId
      new_tsid=TimeSlot.find(:first,:select=>:timeSlotId,:conditions=>"dayOfWeek='#{day_sel}' and startTime='#{st_sel}'").timeSlotId
      
      if add_clicked !=nil
        @button_clicked="Add"
      elsif update_clicked!=nil
        @button_clicked="Update"
      else
        @button_clicked="Delete"
      end
      
      @double_confirm=false
      
      if @button_clicked=="Add"
        @duplicate_class=false
        
        1.upto(duration.to_i) do |d|            
          duplicate_query=SlotAllocation.find_by_sql("Select SA.allocationId from slot_allocations SA, lesson_groups LG, lessons L where L.subjectCode='#{scode}' and SA.lessonId=L.lessonId and SA.groupId=LG.groupId and LG.groupIndex='#{grp_index}' and SA.timeSlotId=#{new_tsid}")
          
          if duplicate_query.length>0
            @duplicate_class=true
            break
          end 
          
          new_tsid+=1   
        end
        
        if @duplicate_class==false
          @del_class_need=false
          
          if occ_status=="Unknown"
            del_alloc_id=params[:delClass]
            @del_class_need=true
            
            new_tsid=TimeSlot.find(:first,:select=>:timeSlotId,:conditions=>"dayOfWeek='#{day_sel}' and startTime='#{st_sel}'").timeSlotId
            
            1.upto(duration.to_i) do |d|
              if freq_sel=="Weekly"
                @venue_clash_query=SlotAllocation.find_by_sql("SELECT SA.allocationId, concat(T.dayOfWeek,' ',T.startTime,'-',T.endTime,' : ',S.subjectCode,' ', S.subjectName,' - ', LG.groupIndex,' (',L.lessonType,') - ', SA.venueName,' (', SA.alloc_lesson_freq,') >> ', ST.staffName) as clash_details FROM slot_allocations SA, lessons L, subjects S, lesson_groups LG, staff_assignments STA, staffs ST, time_slots T where NOT(SA.allocationId=#{del_alloc_id}) and SA.timeSlotId=#{new_tsid} and venueName='#{ven_sel}' and SA.lessonId=STA.lessonId and SA.groupId=STA.groupId and STA.staffId=ST.staffId and  SA.lessonId=L.lessonId and L.subjectCode=S.subjectCode and SA.timeSlotId=T.timeSlotId and SA.groupId=LG.groupId group by SA.allocationId")
              else
                @venue_clash_query=SlotAllocation.find_by_sql("SELECT SA.allocationId, concat(T.dayOfWeek,' ',T.startTime,'-',T.endTime,' : ',S.subjectCode,' ', S.subjectName,' - ', LG.groupIndex,' (',L.lessonType,') - ', SA.venueName,' (', SA.alloc_lesson_freq,') >> ', ST.staffName) as clash_details FROM slot_allocations SA, lessons L, subjects S, lesson_groups LG, staff_assignments STA, staffs ST, time_slots T where NOT(SA.allocationId=#{del_alloc_id}) and SA.timeSlotId=#{new_tsid} and venueName='#{ven_sel}' and (alloc_lesson_freq='#{freq_sel}' Or alloc_lesson_freq='Weekly') and SA.lessonId=STA.lessonId and SA.groupId=STA.groupId and STA.staffId=ST.staffId and  SA.lessonId=L.lessonId and L.subjectCode=S.subjectCode and SA.timeSlotId=T.timeSlotId and SA.groupId=LG.groupId group by SA.allocationId")
              end
              
              if @venue_clash_query.length>0
                occ_status="Occupied"
                break
              end
              new_tsid+=1      
            end
            
          end   
          
          if occ_status=="Occupied"
            @double_confirm=true 
            
            if @del_class_need
              @confirm_del=false
              @del_id=del_alloc_id
            end
            
            new_tsid=TimeSlot.find(:first,:select=>:timeSlotId,:conditions=>"dayOfWeek='#{day_sel}' and startTime='#{st_sel}'").timeSlotId
            
            1.upto(duration.to_i) do |d|
              
              if freq_sel=="Weekly"
                @venue_clash_query=SlotAllocation.find_by_sql("SELECT SA.allocationId,SA.lessonId, concat(T.dayOfWeek,' ',T.startTime,'-',T.endTime,' : ',S.subjectCode,' ', S.subjectName,' - ', LG.groupIndex,' (',L.lessonType,') - ', SA.venueName,' (', SA.alloc_lesson_freq,') >> ', ST.staffName) as clash_details FROM slot_allocations SA, lessons L, subjects S, lesson_groups LG, staff_assignments STA, staffs ST, time_slots T where SA.timeSlotId=#{new_tsid} and venueName='#{ven_sel}' and SA.lessonId=STA.lessonId and SA.groupId=STA.groupId and STA.staffId=ST.staffId and  SA.lessonId=L.lessonId and L.subjectCode=S.subjectCode and SA.timeSlotId=T.timeSlotId and SA.groupId=LG.groupId group by SA.allocationId")
              else
                @venue_clash_query=SlotAllocation.find_by_sql("SELECT SA.allocationId,SA.lessonId, concat(T.dayOfWeek,' ',T.startTime,'-',T.endTime,' : ',S.subjectCode,' ', S.subjectName,' - ', LG.groupIndex,' (',L.lessonType,') - ', SA.venueName,' (', SA.alloc_lesson_freq,') >> ', ST.staffName) as clash_details FROM slot_allocations SA, lessons L, subjects S, lesson_groups LG, staff_assignments STA, staffs ST, time_slots T where SA.timeSlotId=#{new_tsid} and venueName='#{ven_sel}' and (alloc_lesson_freq='#{freq_sel}' Or alloc_lesson_freq='Weekly') and SA.lessonId=STA.lessonId and SA.groupId=STA.groupId and STA.staffId=ST.staffId and  SA.lessonId=L.lessonId and L.subjectCode=S.subjectCode and SA.timeSlotId=T.timeSlotId and SA.groupId=LG.groupId group by SA.allocationId")
              end
              
              if @venue_clash_query.length>0
                shared_query=SharedSubjectCode.find(:all, :conditions=>"sharedType like '%#{class_type}%' and sharedSubjectCodes like '%#{scode}%'")
                shared_ok=false
                
                if shared_query.length==1
                  shared_sub_codes=shared_query[0].sharedSubjectCodes
                  0.upto(@venue_clash_query.length-1) do |cq|
                    if shared_sub_codes.include?(Lesson.find(@venue_clash_query[cq].lessonId).subjectCode.to_s)==false
                      shared_ok=true
                      @venue_clash_query[0]=@venue_clash_query[cq]
                      break
                    end            
                  end
                  
                  if shared_ok==false
                    @double_confirm=false
                    @have_shared=true
                  end
                else
                  shared_ok=true
                end
                
                if shared_ok
                  @parameter_list=scode+"-"+day_sel+"-"+st_sel+"-"+et_sel+"-"+duration+"-"+class_type+"-"+grp_index+"-"+ven_sel+"-"+"Unoccupied"+"-"+freq_sel+"-"+staff_id
                  @tw=teach_week_list
                  break  
                end  
                
              end
              
              new_tsid+=1      
            end
            
          end
          
          if occ_status!="Occupied" || @double_confirm==false
            
            if params[:delClass]!=nil
              del_alloc_id=params[:delClass]
              old_tsid=SlotAllocation.find(del_alloc_id).timeSlotId
              SlotAllocation.delete(del_alloc_id)
              query_details=SlotAllocation.find_by_sql("SELECT SA.allocationId as allocId, L.lessonType, concat(LG.groupIndex,'-',SA.venueName,'(',SA.alloc_lesson_freq,')') as details, SA.groupId FROM slot_allocations SA, lessons L, lesson_groups LG where L.subjectCode='#{scode}' and SA.timeSlotId=#{old_tsid} and SA.lessonId=L.lessonId and SA.groupId=LG.groupId group by allocId")
              @del_class=Array.new
              
              0.upto(query_details.length-1) do |qd|
                temp_string=query_details[qd].allocId.to_s+":"+query_details[qd].lessonType+":"+query_details[qd].details
                @del_class[qd]=temp_string
              end
              
              @del_class_info=scode+":"+old_tsid.to_s
              @confirm_del=true
            end
            
            new_tsid=TimeSlot.find(:first,:select=>:timeSlotId,:conditions=>"dayOfWeek='#{day_sel}' and startTime='#{st_sel}'").timeSlotId
            @all_class=Array.new
            @class_info=Array.new
            
            1.upto(duration.to_i) do |d|
              sa=SlotAllocation.new
              sa.lessonId=lesson_id
              sa.groupId=grp_id
              sa.venueName=ven_sel
              sa.timeSlotId=new_tsid
              sa.alloc_lesson_freq=freq_sel
              sa.lessonWeek=lessonWeek
              sa.save
              query_details=SlotAllocation.find_by_sql("SELECT SA.allocationId as allocId, L.lessonType, concat(LG.groupIndex,'-',SA.venueName,'(',SA.alloc_lesson_freq,')') as details, SA.groupId FROM slot_allocations SA, lessons L, lesson_groups LG where L.subjectCode='#{scode}' and SA.timeSlotId=#{new_tsid} and SA.lessonId=L.lessonId and SA.groupId=LG.groupId group by allocId")
              details_arr=Array.new
              
              0.upto(query_details.length-1) do |qd|
                temp_string=query_details[qd].allocId.to_s+":"+query_details[qd].lessonType+":"+query_details[qd].details+":"+query_details[qd].groupId.to_s
                details_arr[qd]=temp_string
              end
              
              @all_class[d-1]=details_arr
              @class_info[d-1]=scode+":"+new_tsid.to_s
              query_staff=StaffAssignment.find(:first,:conditions=>"groupId =#{grp_id} and lessonId=#{lesson_id}")
              
              #only new lecturer will be added into staff_assignments table
              if staff_id.to_i!=0
                if query_staff.staffId==0
                  query_staff.update_attribute :staffId,staff_id
                  query_staff.update_attribute :teachLessonWeek,teach_week_list
                else
                  sta=StaffAssignment.new
                  sta.groupId=grp_id
                  sta.lessonId=lesson_id
                  sta.staffId=staff_id
                  sta.teachLessonWeek=teach_week_list
                  sta.save
                end
              end   
              
              new_tsid+=1
            end
          end
        end
        
      elsif @button_clicked=="Update"      
        current_slot=SlotAllocation.find(alloc_id)
        @handle_add=false
        @duplicate_class=false
        
        1.upto(duration.to_i) do |d|
          
          duplicate_query=SlotAllocation.find_by_sql("Select SA.allocationId from slot_allocations SA, lesson_groups LG, lessons L where L.subjectCode='#{scode}' and SA.lessonId=L.lessonId and SA.groupId=LG.groupId and LG.groupIndex='#{grp_index}' and SA.timeSlotId=#{new_tsid}")
          
          if duplicate_query.length>0
            @duplicate_class=true
            break
          end 
          new_tsid+=1   
        end
        
        if @duplicate_class==false || current_slot.groupId==grp_id
          @duplicate_class=false
          new_tsid=TimeSlot.find(:first,:select=>:timeSlotId,:conditions=>"dayOfWeek='#{day_sel}' and startTime='#{st_sel}'").timeSlotId
          
          if duration.to_i==1
            old_tsid=current_slot.timeSlotId
            #remove || current_slot.venueName==ven_sel
            old_grpId=current_slot.groupId
            
            if freq_sel=="Weekly"
              @venue_clash_query=SlotAllocation.find_by_sql("SELECT SA.allocationId,SA.lessonId, concat(T.dayOfWeek,' ',T.startTime,'-',T.endTime,' : ',S.subjectCode,' ', S.subjectName,' - ', LG.groupIndex,' (',L.lessonType,') - ', SA.venueName,' (', SA.alloc_lesson_freq,') >> ', ST.staffName) as clash_details FROM slot_allocations SA, lessons L, subjects S, lesson_groups LG, staff_assignments STA, staffs ST, time_slots T where SA.timeSlotId=#{new_tsid} and venueName='#{ven_sel}' and SA.lessonId=STA.lessonId and SA.groupId=STA.groupId and STA.staffId=ST.staffId and  SA.lessonId=L.lessonId and L.subjectCode=S.subjectCode and SA.timeSlotId=T.timeSlotId and SA.groupId!='#{old_grpId}' and SA.groupId=LG.groupId group by SA.allocationId")
            else
              @venue_clash_query=SlotAllocation.find_by_sql("SELECT SA.allocationId,SA.lessonId, concat(T.dayOfWeek,' ',T.startTime,'-',T.endTime,' : ',S.subjectCode,' ', S.subjectName,' - ', LG.groupIndex,' (',L.lessonType,') - ', SA.venueName,' (', SA.alloc_lesson_freq,') >> ', ST.staffName) as clash_details FROM slot_allocations SA, lessons L, subjects S, lesson_groups LG, staff_assignments STA, staffs ST, time_slots T where SA.timeSlotId=#{new_tsid} and venueName='#{ven_sel}' and (alloc_lesson_freq='#{freq_sel}' Or alloc_lesson_freq='Weekly') and SA.lessonId=STA.lessonId and SA.groupId=STA.groupId and STA.staffId=ST.staffId and  SA.lessonId=L.lessonId and L.subjectCode=S.subjectCode and SA.timeSlotId=T.timeSlotId and SA.groupId!='#{old_grpId}'and SA.groupId=LG.groupId group by SA.allocationId")
            end
              
            if @venue_clash_query.length>0
              shared_query=SharedSubjectCode.find(:all, :conditions=>"sharedType like '%#{class_type}%' and sharedSubjectCodes like '%#{scode}%'")
              shared_ok=false
              if shared_query.length==1
                shared_sub_codes=shared_query[0].sharedSubjectCodes
                0.upto(@venue_clash_query.length-1) do |cq|
                  if shared_sub_codes.include?(Lesson.find(@venue_clash_query[cq].lessonId).subjectCode.to_s)==false
                    shared_ok=true
                    @venue_clash_query[0]=@venue_clash_query[cq]
                    break
                  end            
                end
              else
                shared_ok=true
              end
            else
              shared_ok=false
            end
            
            if occ_status=="Unoccupied" || shared_ok==false
              current_slot.update_attribute :timeSlotId,new_tsid
              current_slot.update_attribute :lessonId,lesson_id
              current_slot.update_attribute :groupId,grp_id
              current_slot.update_attribute :venueName, ven_sel
              current_slot.update_attribute :alloc_lesson_freq, freq_sel
              current_slot.update_attribute :lessonWeek, lessonWeek
              
              @class_info=Array.new
              @all_class=Array.new
              
              query_details=SlotAllocation.find_by_sql("SELECT SA.allocationId as allocId, L.lessonType, concat(LG.groupIndex,'-',SA.venueName,'(',SA.alloc_lesson_freq,')') as details, SA.groupId FROM slot_allocations SA, lessons L, lesson_groups LG where L.subjectCode='#{scode}' and SA.timeSlotId=#{old_tsid} and SA.lessonId=L.lessonId and SA.groupId=LG.groupId group by allocId")
              details_arr=Array.new
              0.upto(query_details.length-1) do |qd|
                temp_string=query_details[qd].allocId.to_s+":"+query_details[qd].lessonType+":"+query_details[qd].details+":"+query_details[qd].groupId.to_s
                details_arr[qd]=temp_string
              end
              
              @all_class[0]=details_arr
              @class_info[0]=scode+":"+old_tsid.to_s
              
              count=1
              if old_tsid.to_i!=new_tsid.to_i
              
                query_details=SlotAllocation.find_by_sql("SELECT SA.allocationId as allocId, L.lessonType, concat(LG.groupIndex,'-',SA.venueName,'(',SA.alloc_lesson_freq,')') as details, SA.groupId FROM slot_allocations SA, lessons L, lesson_groups LG where L.subjectCode='#{scode}' and SA.timeSlotId=#{new_tsid} and SA.lessonId=L.lessonId and SA.groupId=LG.groupId group by allocId")
                details_arr=Array.new
                
                0.upto(query_details.length-1) do |qd|
                  temp_string=query_details[qd].allocId.to_s+":"+query_details[qd].lessonType+":"+query_details[qd].details+":"+query_details[qd].groupId.to_s
                  details_arr[qd]=temp_string
                end
                
                @all_class[count]=details_arr
                @class_info[count]=scode+":"+new_tsid.to_s
                count+=1
              end
              
              
              #for shared subject
              shared_query=SharedSubjectCode.find(:all, :conditions=>"sharedType like '%#{class_type}%' and sharedSubjectCodes like '%#{scode}%'")
              if shared_query.length==1
                
                scode_arr=Array.new
                scode_arr=shared_query[0].sharedSubjectCodes.split(",")
                0.upto(scode_arr.length-1) do |sc|
                  if scode_arr[sc]!=scode
                    shared_slot=SlotAllocation.find(alloc_id)
                    shared_lesson_id=Lesson.find(:first,:conditions=>"lessonType='#{class_type}' and subjectCode='#{scode_arr[sc]}'").lessonId
                    shared_slot=SlotAllocation.find(:all,:conditions=>"lessonId='#{shared_lesson_id}' and timeSlotId='#{old_tsid}'")
                    
                    if shared_slot.length>0
                      shared_slot[0].update_attribute :timeSlotId,new_tsid
                      shared_slot[0].update_attribute :venueName, ven_sel
                      shared_slot[0].update_attribute :alloc_lesson_freq, freq_sel
                      shared_slot[0].update_attribute :lessonWeek, lessonWeek
                      
                      query_details=SlotAllocation.find_by_sql("SELECT SA.allocationId as allocId, L.lessonType, concat(LG.groupIndex,'-',SA.venueName,'(',SA.alloc_lesson_freq,')') as details, SA.groupId FROM slot_allocations SA, lessons L, lesson_groups LG where L.subjectCode='#{scode_arr[sc]}' and SA.timeSlotId=#{old_tsid} and SA.lessonId=L.lessonId and SA.groupId=LG.groupId group by allocId")
                      details_arr=Array.new
                      0.upto(query_details.length-1) do |qd|
                        temp_string=query_details[qd].allocId.to_s+":"+query_details[qd].lessonType+":"+query_details[qd].details+":"+query_details[qd].groupId.to_s
                        details_arr[qd]=temp_string
                      end
                      
                      @all_class[count]=details_arr
                      @class_info[count]=scode_arr[sc].to_s+":"+old_tsid.to_s
                      
                      count+=1
                      if old_tsid.to_i!=new_tsid.to_i
                        
                        query_details=SlotAllocation.find_by_sql("SELECT SA.allocationId as allocId, L.lessonType, concat(LG.groupIndex,'-',SA.venueName,'(',SA.alloc_lesson_freq,')') as details, SA.groupId FROM slot_allocations SA, lessons L, lesson_groups LG where L.subjectCode='#{scode_arr[sc]}' and SA.timeSlotId=#{new_tsid} and SA.lessonId=L.lessonId and SA.groupId=LG.groupId group by allocId")
                        details_arr=Array.new                      
                        0.upto(query_details.length-1) do |qd|
                          temp_string=query_details[qd].allocId.to_s+":"+query_details[qd].lessonType+":"+query_details[qd].details+":"+query_details[qd].groupId.to_s
                          details_arr[qd]=temp_string
                        end
                        
                        @all_class[count]=details_arr
                        @class_info[count]=scode_arr[sc].to_s+":"+new_tsid.to_s
                        
                        count+=1
                      end
                    end
                    
                  end
                  
                  
                end
                
                
              end
              
              
            else
              
              @double_confirm=true              
              @parameter_list=scode+"-"+day_sel+"-"+st_sel+"-"+et_sel+"-"+duration+"-"+class_type+"-"+grp_index+"-"+ven_sel+"-"+"Unoccupied"+"-"+freq_sel+"-"+alloc_id
              
            end
            
          else
            
            if freq_sel=="Weekly"
              teach_week_list="1,2,3,4,5,6,7,8,9,10,11,12,13"
            elsif freq_sel=="Odd"
              teach_week_list="1,3,5,7,9,11,13"
            else
             teach_week_list="2,4,6,8,10,12"
           end
           
            @handle_add=true
            @parameter_list=scode+"-"+day_sel+"-"+st_sel+"-"+et_sel+"-"+duration+"-"+class_type+"-"+grp_index+"-"+ven_sel+"-"+"Unknown"+"-"+freq_sel+"-0"+"-"+alloc_id
            @tw=teach_week_list
            
          end
          
        end
        
      else
        
        SlotAllocation.delete(alloc_id)      
        query_details=SlotAllocation.find_by_sql("SELECT SA.allocationId as allocId, L.lessonType, concat(LG.groupIndex,'-',SA.venueName,'(',SA.alloc_lesson_freq,')') as details, SA.groupId FROM slot_allocations SA, lessons L, lesson_groups LG where L.subjectCode='#{scode}' and SA.timeSlotId=#{new_tsid} and SA.lessonId=L.lessonId and SA.groupId=LG.groupId group by allocId")
        
        @all_class=Array.new
        0.upto(query_details.length-1) do |qd|
          temp_string=query_details[qd].allocId.to_s+":"+query_details[qd].lessonType+":"+query_details[qd].details+":"+query_details[qd].groupId.to_s
          @all_class[qd]=temp_string
        end
        
        @class_info=scode+":"+new_tsid.to_s
      end
      
    else
      @no_button_clicked=true
    end
    
    render :layout=>false
    
  end
  
  def select_group
    
    scode_list=params[:scodeList]
    
    scode_arr=Array.new
    scode_arr=scode_list.split("-")
    query_string=""
    0.upto(scode_arr.length-1) do |sc|
      query_string+= "L.subjectCode='"+scode_arr[sc]+"' or "
    end
    
    query_string=query_string[0,query_string.length-3]
    
    @grp_list=LessonGroup.find_by_sql("SELECT SA.groupId, LG.groupIndex FROM slot_allocations SA,lessons L, lesson_groups LG where (#{query_string}) and SA.lessonId=L.lessonId and SA.groupId=LG.groupId group by LG.groupIndex order by LG.groupIndex")
    
    @cell_list_arr=Array.new
    
    
    0.upto(scode_arr.length-1) do |sc|
      query=SlotAllocation.find_by_sql("SELECT SA.groupId, L.lessonType, concat('cellListItem_',L.subjectCode,'_', SA.timeSlotId,'_', SA.groupId) as cellList FROM slot_allocations SA, lessons L, lesson_groups LG where SA.lessonId=L.lessonId and L.subjectCode='#{scode_arr[sc]}' and SA.groupId=LG.groupId")
      0.upto(query.length-1) do |q|
        @cell_list_arr[@cell_list_arr.length]=query[q].groupId.to_s+":"+query[q].lessonType+":"+query[q].cellList
        
      end      
    end
    
    
    render :layout=>false
  
  end
  
  def check_lec_grp_id
  
    grp_id_list=params[:grpIdList]
    
    grp_id_arr=Array.new
    grp_id_arr=grp_id_list.split("-")
    query_string=""
    0.upto(grp_id_arr.length-1) do |gi|
      query_string+= "SA.groupId="+grp_id_arr[gi].to_s+" or "
    end
    
    query_string=query_string[0,query_string.length-3]
    
    lec_grp_id_list=LessonGroup.find_by_sql("Select Distinct LG.groupId from lesson_groups LG, slot_allocations SA where SA.groupId=LG.groupId and SA.lessonId in (Select lessonId from lessons where lessonType='Lec' and subjectCode in (Select Distinct L.subjectCode from lessons L, slot_allocations SA where (#{query_string}) and SA.lessonId=L.lessonId))")
    
    0.upto(lec_grp_id_list.length-1) do |lg|
      grp_id_list+="-"+lec_grp_id_list[lg].groupId.to_s
    end
    
    @grp_id_full_list=grp_id_list
    
  render :layout=>false
  end
  
  def schedule_staff_slot
    @scode=params[:scode]
    
    session[:tsid]=params[:tsid]
    tsid=session[:tsid]
    
    query=Subject.find(:first,:conditions=>"subjectCode='#{@scode}'")
    @au=query.acad_unit
    
    @slot_details=SlotAllocation.find_by_sql("SELECT SA.allocationId as allocId, L.lessonType,LG.groupIndex,SA.venueName, SA.groupId, SA.alloc_lesson_freq as freq, STA.teachLessonWeek, ST.staffName, ST.staffId,TS.startTime, TS.endTime, TS.dayOfWeek FROM slot_allocations SA,lessons L, lesson_groups LG, time_slots TS, staffs ST, staff_assignments STA where L.subjectCode='#{@scode}' and SA.timeSlotId=#{tsid} and SA.lessonId=L.lessonId and SA.groupId=LG.groupId and ST.staffId=STA.staffId and STA.lessonId=SA.lessonId and STA.groupId=SA.groupId group by allocId")
    @startT=TimeSlot.find_by_sql("select time(startTime) as st from time_slots where timeSlotId=#{tsid}")[0].st
    @endT=TimeSlot.find_by_sql("select time(endTime) as et from time_slots where timeSlotId=#{tsid}")[0].et
    @day_choose=TimeSlot.find(tsid).dayOfWeek
    
    @lecturer_list = Staff.find_by_sql("SELECT staffId, staffName, subjectAssigned FROM staffs where (subjectAssigned like '%#{@scode}%' or subjectAssigned ='') order by staffName")
    @exist_lecturer_list=StaffAssignment.find_by_sql("SELECT STA.staffId, ST.staffName, L.lessonType, LG.groupIndex FROM lessons L, staff_assignments STA, lesson_groups LG, staffs ST where L.subjectCode='#{@scode}' and L.lessonId=STA.lessonId and STA.groupId=LG.groupId and STA.staffId=ST.staffId")
    
    render :layout=>false
  end
  
   def update_teach_weeks
    scode=params[:subcode]
    class_type=params[:ctSel]
    grp_index=params[:grpIndex]
    staff_id=params[:staffId]
    teach_week_list=params[:teachWeekList]
    
    if staff_id=="0"
    else
      lesson_id=Lesson.find(:first,:select=>:lessonId, :conditions=>"subjectCode='#{scode}' and lessonType='#{class_type}'").lessonId
      grp_id=LessonGroup.find(:first,:select=>:groupId,:conditions=>"groupIndex='#{grp_index}'").groupId      
      entry=StaffAssignment.find(:first,:conditions=>"groupId =#{grp_id} and lessonId=#{lesson_id} and staffId=#{staff_id}")    
    
      entry.update_attribute :teachLessonWeek, teach_week_list
    end
    render :nothing=>true
  end
    
end
