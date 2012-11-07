class DbSwitchController < ApplicationController
  layout 'standard'
  
  def db_switch
    if session[:user]==nil
      redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
    else
      @back_up_list=BackupEntry.find(:all,:order=>"year,semester,version")
      @back_up_year=BackupEntry.find_by_sql("SELECT distinct year FROM backup_entries")
      @cur_year=BackupEntry.find(:first,:conditions=>"currentflag=1").year
      @cur_sem=BackupEntry.find(:first,:conditions=>"currentflag=1").semester
      @cur_ver=BackupEntry.find(:first,:conditions=>"currentflag=1").version
    end
  end
  
  def process_db_switch
    
    @save_action=params[:saveBtn]
    
    if @save_action=="Save"      
      
      @year=params[:yearSave].strip
      @sem=params[:semSave]
      @ver=params[:verSave].strip
      answer=params[:answer]
      
      @backup_id=@year[2,2]+@year[7,2]+"S"+@sem+"_"+@ver   
      
      path="C:/TPS/tps/public/db_files/"+@backup_id+"_"
      lesson_file=path+"lessons.txt"
      lesson_group_file=path+"lesson_groups.txt"
      shared_sub_code_file=path+"share_subject_codes.txt"
      slot_alloc_file=path+"slot_allocations.txt"
      staff_assign_file=path+"staff_assignments.txt"
      staff_file=path+"staffs.txt"
      sub_file=path+"subjects.txt"
      sub_list_file=path+"subject_lists.txt"
      venue_file=path+"venues.txt"
      index_subject_file=path+"index_subjects.txt"
      
      backup_entry_file=path+"backup_entries.txt"
      login_file=path+"logins.txt"
      time_slot_file=path+"time_slots.txt"
      reference_subject_file=path+"reference_subjects.txt"
      
      if File.exist?(lesson_file) && answer==nil
        redirect_to :controller=>'db_switch', :action=>'overwrite_option', :yearSave=>@year, :semSave=>@sem,:verSave=>@ver,:writeStaff=>@write_staff,:writeVenue=>@write_venue
      else
        if File.exist?(lesson_file)==false || answer=="Over Write" 
          exist_entry=BackupEntry.find(:all,:conditions=>"backupId='#{@backup_id}'")
          
          
          be_query=BackupEntry.find(:first,:conditions=>"currentflag=1")
          be_query.update_attribute :currentflag,0
          
          if exist_entry.length==0    
            
            be=BackupEntry.new
            be.id=@backup_id
            be.year=@year
            be.semester=@sem
            be.version=@ver
            be.currentflag=1
            be.staff=0
            be.venue=0
            
            be.save
          else
            be_query=BackupEntry.find(@backup_id)
            be_query.update_attribute :currentflag,1
          end
            
          if File.exist?(lesson_file)
            File.delete(lesson_file)
          end    
          if File.exist?(lesson_group_file)
            File.delete(lesson_group_file)
          end    
          if File.exist?(shared_sub_code_file)
            File.delete(shared_sub_code_file)
          end
          if File.exist?(slot_alloc_file)
            File.delete(slot_alloc_file)
          end
          if File.exist?(staff_assign_file)
            File.delete(staff_assign_file)
          end
          if File.exist?(sub_file)
            File.delete(sub_file)
          end
          if File.exist?(sub_list_file)
            File.delete(sub_list_file)
	end
	  if File.exist?(index_subject_file)
            File.delete(index_subject_file)
          end   

	  if File.exist?(time_slot_file)
            File.delete(time_slot_file)
	end  
 	  if File.exist?(reference_subject_file)
            File.delete(reference_subject_file)
	end
	  if File.exist?(backup_entry_file)
            File.delete(backup_entry_file)
	end  
 	  if File.exist?(login_file)
            File.delete(login_file)
	end      
    
	ActiveRecord::Base.connection.execute("Select * from reference_subjects INTO OUTFILE '#{reference_subject_file}'") 
 	ActiveRecord::Base.connection.execute("Select * from time_slots INTO OUTFILE '#{time_slot_file}'") 
	ActiveRecord::Base.connection.execute("Select * from backup_entries INTO OUTFILE '#{backup_entry_file}'") 
	ActiveRecord::Base.connection.execute("Select * from logins INTO OUTFILE '#{login_file}'")	

	  ActiveRecord::Base.connection.execute("Select * from index_subjects INTO OUTFILE '#{index_subject_file}'")
          ActiveRecord::Base.connection.execute("Select * from lessons INTO OUTFILE '#{lesson_file}'") 
          ActiveRecord::Base.connection.execute("Select * from lesson_groups INTO OUTFILE '#{lesson_group_file}'") 
          ActiveRecord::Base.connection.execute("Select * from shared_subject_codes INTO OUTFILE '#{shared_sub_code_file}'") 
          ActiveRecord::Base.connection.execute("Select * from slot_allocations INTO OUTFILE '#{slot_alloc_file}'") 
          ActiveRecord::Base.connection.execute("Select * from staff_assignments INTO OUTFILE '#{staff_assign_file}'") 
          ActiveRecord::Base.connection.execute("Select * from subjects INTO OUTFILE '#{sub_file}'") 
          ActiveRecord::Base.connection.execute("Select * from subject_lists INTO OUTFILE '#{sub_list_file}'")
	  
          
          
            be_query=BackupEntry.find(:first,:conditions=>"venue=1")
            be_query.update_attribute :venue,0
                
            be_query=BackupEntry.find(@backup_id)
            be_query.update_attribute :venue,1
            if File.exist?(venue_file)
              File.delete(venue_file)
            end
            ActiveRecord::Base.connection.execute("Select * from venues INTO OUTFILE '#{venue_file}'") 
         
          
            be_query=BackupEntry.find(:first,:conditions=>"staff=1")
            be_query.update_attribute :staff,0
                
            be_query=BackupEntry.find(@backup_id)
            be_query.update_attribute :staff,1
            if File.exist?(staff_file)
              File.delete(staff_file)
            end
            ActiveRecord::Base.connection.execute("Select * from staffs where staffId!=0 INTO OUTFILE '#{staff_file}'") 
          
        end
      end
    else

      ReferenceSubjects.delete_all
      TimeSlot.delete_all    
      IndexSubject.delete_all
      Subject.delete_all
      SubjectList.delete_all
      StaffAssignment.delete_all
      SlotAllocation.delete_all
      SharedSubjectCode.delete_all
      Lesson.delete_all
      LessonGroup.delete_all
      
      @action=params[:createLoad]
      
      if @action=="load"
        @year=params[:yearSel]
        @sem=params[:semSel]
        @ver=params[:verSel]
        
        @year_save=params[:yearSave2]
        if @year_save!=""
          @save=true
          @sem_save=params[:semSave2]
          @ver_save=params[:verSave2]
          @backup_id_save=@year_save[2,2]+@year_save[7,2]+"S"+@sem_save+"_"+@ver_save
        else
          @save=false
        end
        
        year1=@year[2,2]
        year2=@year[7,2]
        @backup_id=year1+year2+"S"+@sem+"_"+@ver
        
        path="C:/TPS/tps/public/db_files/"+@backup_id+"_"
        lesson_file=path+"lessons.txt"
        lesson_group_file=path+"lesson_groups.txt"
        shared_sub_code_file=path+"share_subject_codes.txt"
        slot_alloc_file=path+"slot_allocations.txt"
        staff_assign_file=path+"staff_assignments.txt"
        staff_file=path+"staffs.txt"
        sub_file=path+"subjects.txt"
        sub_list_file=path+"subject_lists.txt"
        venue_file=path+"venues.txt"
        index_subject_file=path+"index_subjects.txt"
	
      backup_entry_file=path+"backup_entries.txt"
      login_file=path+"logins.txt"
      time_slot_file=path+"time_slots.txt"
      reference_subject_file=path+"reference_subjects.txt"
        
        be_query=BackupEntry.find(:first,:conditions=>"currentflag=1")
        be_query.update_attribute :currentflag,0
        
        be_query=BackupEntry.find(@backup_id)
        be_query.update_attribute :currentflag,1
        
        
          if File.exist?(venue_file)
            be_query=BackupEntry.find(:first,:conditions=>"venue=1")
            be_query.update_attribute :venue,0
            
            be_query=BackupEntry.find(@backup_id)
            be_query.update_attribute :venue,1
            Venue.delete_all
            ActiveRecord::Base.connection.execute("Load DATA INFILE '#{venue_file}' INTO TABLE venues")
            @venue_status="ok"
          else
            @venue_status="NotOK"
          end        
                   
   
	ActiveRecord::Base.connection.execute("Load DATA INFILE '#{reference_subject_file}' INTO TABLE reference_subjects")   
        ActiveRecord::Base.connection.execute("Load DATA INFILE '#{time_slot_file}' INTO TABLE time_slots")
	ActiveRecord::Base.connection.execute("Load DATA INFILE '#{sub_file}' INTO TABLE subjects")   
        ActiveRecord::Base.connection.execute("Load DATA INFILE '#{sub_list_file}' INTO TABLE subject_lists")       
        ActiveRecord::Base.connection.execute("Load DATA INFILE '#{lesson_file}' INTO TABLE lessons")   
        ActiveRecord::Base.connection.execute("Load DATA INFILE '#{lesson_group_file}' INTO TABLE lesson_groups") 
        ActiveRecord::Base.connection.execute("Load DATA INFILE '#{shared_sub_code_file}' INTO TABLE shared_subject_codes")
        ActiveRecord::Base.connection.execute("Load DATA INFILE '#{slot_alloc_file}' INTO TABLE slot_allocations")  
        ActiveRecord::Base.connection.execute("Load DATA INFILE '#{staff_assign_file}' INTO TABLE staff_assignments")  
	ActiveRecord::Base.connection.execute("Load DATA INFILE '#{index_subject_file}' INTO TABLE index_subjects") 
	
	if File.exist?(staff_file)
            be_query=BackupEntry.find(:first,:conditions=>"staff=1")
            be_query.update_attribute :staff,0
            
            be_query=BackupEntry.find(@backup_id)
            be_query.update_attribute :staff,1
            Staff.delete_all "staffId!=0"
            ActiveRecord::Base.connection.execute("Load DATA INFILE '#{staff_file}' INTO TABLE staffs" )
            @staff_status="ok"
          else
            @staff_status="NotOK"
	end     
        
      else
        @year=params[:yearSel2]
        @sem=params[:semSel2]
        @ver=params[:verSel2]
        
        year1=@year[2,2]
        year2=@year[7,2]
        @backup_id=year1+year2+"S"+@sem+"_"+@ver
        
        exist_entry=BackupEntry.find(:all,:conditions=>"year='#{@year}' and semester='#{@sem}' and version='#{@ver}'")
      
        if exist_entry.length>0
          @exist=true
        else
          @exist=false
          be_query=BackupEntry.find(:first,:conditions=>"currentflag=1")
          be_query.update_attribute :currentflag,0
          
          be=BackupEntry.new
          be.id=@backup_id
          be.year=@year
          be.semester=@sem
          be.version=@ver
          be.currentflag=1
          be.venue=0
          be.staff=0
          be.save
          
          path="C:/TPS/tps/public/db_files/"+@backup_id+"_"
          lesson_file=path+"lessons.txt"
          lesson_group_file=path+"lesson_groups.txt"
          shared_sub_code_file=path+"share_subject_codes.txt"
          slot_alloc_file=path+"slot_allocations.txt"
          staff_assign_file=path+"staff_assignments.txt"
          staff_file=path+"staffs.txt"
          sub_file=path+"subjects.txt"
          sub_list_file=path+"subject_lists.txt"
          venue_file=path+"venues.txt"
	  index_subject_file=path+"index_subjects.txt"

      backup_entry_file=path+"backup_entries.txt"
      login_file=path+"logins.txt"
      time_slot_file=path+"time_slots.txt"
      reference_subject_file=path+"reference_subjects.txt"

 	ActiveRecord::Base.connection.execute("Select * from time_slots INTO OUTFILE '#{time_slot_file}'") 
	ActiveRecord::Base.connection.execute("Select * from reference_subjects INTO OUTFILE '#{reference_subject_file}'") 
	ActiveRecord::Base.connection.execute("Select * from backup_entries INTO OUTFILE '#{backup_entry_file}'") 
	ActiveRecord::Base.connection.execute("Select * from logins INTO OUTFILE '#{login_file}'")	
	
	  ActiveRecord::Base.connection.execute("Select * from index_subjects INTO OUTFILE '#{index_subject_file}'")
          ActiveRecord::Base.connection.execute("Select * from lessons INTO OUTFILE '#{lesson_file}'") 
          ActiveRecord::Base.connection.execute("Select * from lesson_groups INTO OUTFILE '#{lesson_group_file}'") 
          ActiveRecord::Base.connection.execute("Select * from shared_subject_codes INTO OUTFILE '#{shared_sub_code_file}'") 
          ActiveRecord::Base.connection.execute("Select * from slot_allocations INTO OUTFILE '#{slot_alloc_file}'") 
          ActiveRecord::Base.connection.execute("Select * from staff_assignments INTO OUTFILE '#{staff_assign_file}'") 
          ActiveRecord::Base.connection.execute("Select * from subjects INTO OUTFILE '#{sub_file}'") 
          ActiveRecord::Base.connection.execute("Select * from subject_lists INTO OUTFILE '#{sub_list_file}'") 
          
          
          
        end
      end
    end
  end
  
  def overwrite_option
    @year=params[:yearSave]
    @sem=params[:semSave]
    @ver=params[:verSave]
  end
  
  
end
