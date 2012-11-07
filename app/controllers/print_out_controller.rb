class PrintOutController < ApplicationController
	before_filter :login_required
	layout 'standard'
	
	def subject_index_printout
	end
	def process_subject_index_printout
		year=params[:year]
		sem=params[:semester]
		
		subjectindex=File.new("public/files/SubjectIndex.txt","w")
		
		all_indexs=IndexSubject.find_by_sql("Select IndexNumber, AcademicYear, Semester, subjectCode, LectureGroup, TutorialGroup, LaboratoryGroup, DesignGroup, ProjectGroup, SeminarGroup from index_subjects where AcademicYear='#{year}' and Semester='#{sem}' order by subjectCode")
		
		0.upto(all_indexs.length-1) do |sa|
			row=""
			
			index=all_indexs[sa].IndexNumber
			
			acyear=all_indexs[sa].AcademicYear
			
			sem=all_indexs[sa].Semester
			
			scode=all_indexs[sa].subjectCode.strip
			
			scode.length.upto(5) do |sc|
				scode=scode+" "
			end
			
			lc_grp=""
			if all_indexs[sa].LectureGroup!=nil
			lc_grp=all_indexs[sa].LectureGroup.strip
			end
			lc_grp.length.upto(4) do |lc|
				lc_grp=lc_grp+" "
			end
			
			tut_grp=""	
			if all_indexs[sa].TutorialGroup!=nil			
			tut_grp=all_indexs[sa].TutorialGroup.strip
			end
			tut_grp.length.upto(4) do |tu|
				tut_grp=tut_grp+" "
			end
			
			lab_grp=""
			if all_indexs[sa].LaboratoryGroup!=nil	
			lab_grp=all_indexs[sa].LaboratoryGroup.strip
			end
			lab_grp.length.upto(4) do |la|
				lab_grp=lab_grp+" "
			end

			des_grp=""
			if all_indexs[sa].DesignGroup!=nil	
			des_grp=all_indexs[sa].DesignGroup.strip
			end
			des_grp.length.upto(4) do |de|
				des_grp=des_grp+" "
			end

			prj_grp=""
			if all_indexs[sa].ProjectGroup!=nil	
			prj_grp=all_indexs[sa].ProjectGroup.strip
			end
			prj_grp.length.upto(4) do |pj|
				prj_grp=prj_grp+" "
			end

			sem_grp=""
			if all_indexs[sa].SeminarGroup!=nil	
			sem_grp=all_indexs[sa].SeminarGroup.strip
			end
			sem_grp.length.upto(4) do |se|
				sem_grp=sem_grp+" "
			end
			
			row+=year+sem+index+scode+lc_grp+tut_grp+lab_grp+des_grp+prj_grp+sem_grp
			subjectindex.print(row, "\r\n")
		end

		subjectindex.close
		render :nothing=>"true"
	end
	
	def stars_printout
	end
	
	def process_stars_printout
		year=params[:year]
		sem=params[:semester]
		
		stars=File.new("public/files/STARS.txt","w")
		
		all_slots=SlotAllocation.find_by_sql("SELECT L.subjectCode,L.lessonType,LG.groupIndex,T.dayOfWeek,Time(T.startTime) as startT, Time(T.endTime) as endT, SA.venueName, SA.lessonWeek FROM lessons L, lesson_groups LG, slot_allocations SA, time_slots T where SA.lessonId=L.lessonId and SA.groupId=LG.groupId and SA.timeSlotId=T.timeSlotId order by subjectCode")
		0.upto(all_slots.length-1) do |sa|
			row=""
			scode=all_slots[sa].subjectCode.strip
			
			scode.length.upto(5) do |sc|
				scode=scode+" "
			end
			
			class_type=all_slots[sa].lessonType.upcase
			grp_index=all_slots[sa].groupIndex.strip
			
			grp_index.length.upto(4) do |gi|
				grp_index=grp_index+" "
			end
			
			case all_slots[sa].dayOfWeek
				when "Monday"
					day="M"
				when "Tuesday"
					day="T"
				when "Wednesday"
					day="W"
				when "Thursday"
					day="TH"
				when "Friday"
					day="F"
				when "Saturday"
					day="S"
			end
			day=day.strip
		
			day.length.upto(1) do |d|
				day=day+" "
			end 
			
			startT=all_slots[sa].startT[0,5]
			endT=all_slots[sa].endT[0,5]
			
			venue=all_slots[sa].venueName.strip
			
			venue.length.upto(19) do |d|
				venue=venue+" "
			end
			
			lesson_week_arr=Array.new
			lesson_week_arr=all_slots[sa].lessonWeek.split(",")
			
			week=""
			1.upto(13) do |wk|
				exist=false
				0.upto(lesson_week_arr.length-1) do |lw|
					if lesson_week_arr[lw].to_i==wk
						exist=true
						break
					end
				end
				if exist 
					week=week+" "
				else
					week=week+"N"
				end				
			end			
			
			row+=year+sem+scode+class_type+grp_index+day+startT+endT+venue+week
			stars.print(row, "\r\n")
		end
		
		stars.close
		render :nothing=>"true"
	end
	
	def printout_done
		@print=params[:print]
		render :layout=>false
	end
	
	def tt_excel_printout
		if session[:user]==nil
			redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
		else
			@subjects=Subject.find(:all,:order=>"subjectCode")			 
			@subLists=SubjectList.find_by_sql("Select Distinct subjectListName from subject_lists order by subjectListName")
		end
	end
	
	def sub_grp_excel_printout
	end
	
	def process_sub_grp_excel_printout
		file_format=params[:fileFormat]
		tab="\t"
		cr="\n"
		
		if file_format=="byGroup"
			sub_grp=File.new("public/files/SubjectGroup.xls","w")
			row="SUBJECT"+tab+tab+"LECTURE"+tab+tab+tab+"TUTORIAL"+tab+tab+tab+"LABORATORY"
			sub_grp.puts row
			row="Code"+tab+"Name"+tab+"Group"+tab+"Staff"+tab+"Week"+tab+"Group"+tab+"Staff"+tab+"Week"+tab+"Group"+tab+"Staff"+tab+"Week"
			sub_grp.puts row
			
			sub_list=Subject.find(:all,:order=>"subjectCode")
			
			0.upto(sub_list.length-1) do |sa|
				
				lec_list=SlotAllocation.find_by_sql("select LG.groupIndex,ST.staffName,STA.teachLessonWeek from lesson_groups LG,lessons L, slot_allocations SA, staff_assignments STA,staffs ST,subjects S where SA.lessonId=L.lessonId and L.subjectCode=S.subjectCode and SA.groupId=LG.groupId and STA.lessonId=SA.lessonId and STA.groupId=SA.groupId and STA.staffId=ST.staffId and S.subjectCode='#{sub_list[sa].id}' and L.lessonType='Lec' group by LG.groupIndex, ST.staffName order by LG.groupIndex")
				tut_list=SlotAllocation.find_by_sql("select LG.groupIndex,ST.staffName,STA.teachLessonWeek from lesson_groups LG,lessons L, slot_allocations SA, staff_assignments STA,staffs ST,subjects S where SA.lessonId=L.lessonId and L.subjectCode=S.subjectCode and SA.groupId=LG.groupId and STA.lessonId=SA.lessonId and STA.groupId=SA.groupId and STA.staffId=ST.staffId and S.subjectCode='#{sub_list[sa].id}' and L.lessonType='Tut' group by LG.groupIndex, ST.staffName order by LG.groupIndex")
				lab_list=SlotAllocation.find_by_sql("select LG.groupIndex,ST.staffName,STA.teachLessonWeek from lesson_groups LG,lessons L, slot_allocations SA, staff_assignments STA,staffs ST,subjects S where SA.lessonId=L.lessonId and L.subjectCode=S.subjectCode and SA.groupId=LG.groupId and STA.lessonId=SA.lessonId and STA.groupId=SA.groupId and STA.staffId=ST.staffId and S.subjectCode='#{sub_list[sa].id}' and L.lessonType='Lab' group by LG.groupIndex, ST.staffName order by LG.groupIndex")
				
				lec_list_finish=false
				tut_list_finish=false
				lab_list_finish=false
				
				
				row_no=0
				lec_grp_index=""
				tut_grp_index=""
				lab_grp_index=""
				while (!lec_list_finish || !tut_list_finish || !lab_list_finish)
					if row_no==0
						row=sub_list[sa].id+tab+Subject.find(sub_list[sa].id).subjectName
					else
						row=tab
					end
					
					if lec_list[row_no]!=nil
						if lec_list[row_no].groupIndex==lec_grp_index
							row+=tab+tab+lec_list[row_no].staffName+tab+lec_list[row_no].teachLessonWeek
						else
							row+=tab+lec_list[row_no].groupIndex+tab+lec_list[row_no].staffName+tab+lec_list[row_no].teachLessonWeek
						end
						lec_grp_index=lec_list[row_no].groupIndex
					else
						row+=tab+tab+tab
						lec_list_finish=true
					end
					
					if tut_list[row_no]!=nil
						if tut_list[row_no].groupIndex==tut_grp_index
							row+=tab+tab+tut_list[row_no].staffName+tab+tut_list[row_no].teachLessonWeek
						else
							row+=tab+tut_list[row_no].groupIndex+tab+tut_list[row_no].staffName+tab+tut_list[row_no].teachLessonWeek
						end
						tut_grp_index=tut_list[row_no].groupIndex
					else
						row+=tab+tab+tab
						tut_list_finish=true
					end
					
					if lab_list[row_no]!=nil
						if lab_list[row_no].groupIndex==lab_grp_index
							row+=tab+tab+lab_list[row_no].staffName+tab+lab_list[row_no].teachLessonWeek
						else
							row+=tab+lab_list[row_no].groupIndex+tab+lab_list[row_no].staffName+tab+lab_list[row_no].teachLessonWeek
						end
						lab_grp_index=lab_list[row_no].groupIndex
					else
						row+=tab+tab+tab
						lab_list_finish=true
					end
					
					if !lec_list_finish || !tut_list_finish || !lab_list_finish
						sub_grp.puts row
					else
						sub_grp.puts cr
					end
					row_no+=1
					
				end			 
				
			end
			
			
			sub_grp.close
			
		else
			
			sub_grp=File.new("public/files/SubjectGroupByStaff.xls","w")
			
			row="SUBJECT"+tab+tab+"LECTURE"+tab+tab+tab+"TUTORIAL"+tab+tab+tab+"LABORATORY"
			sub_grp.puts row
			row="Code"+tab+"Name"+tab+"Staff"+tab+"Group"+tab+"Hrs(Grp)"+tab+"Staff"+tab+"Group"+tab+"Hrs(Grp)"+tab+"Staff"+tab+"Group"+tab+"Hrs(Grp)"
			sub_grp.puts row
			
			sub_list=Subject.find(:all,:order=>"subjectCode")
			
			0.upto(sub_list.length-1) do |sa|
				
				lec_staff_list=SlotAllocation.find_by_sql("select ST.staffId, ST.staffName from lessons L, slot_allocations SA, staff_assignments STA,staffs ST,subjects S where SA.lessonId=L.lessonId and L.subjectCode=S.subjectCode and SA.groupId=STA.groupId and STA.lessonId=SA.lessonId and STA.staffId=ST.staffId and S.subjectCode='#{sub_list[sa].id}' and L.lessonType='Lec' group by ST.staffName order by ST.staffId")
				tut_staff_list=SlotAllocation.find_by_sql("select ST.staffId, ST.staffName from lessons L, slot_allocations SA, staff_assignments STA,staffs ST,subjects S where SA.lessonId=L.lessonId and L.subjectCode=S.subjectCode and SA.groupId=STA.groupId and STA.lessonId=SA.lessonId and STA.staffId=ST.staffId and S.subjectCode='#{sub_list[sa].id}' and L.lessonType='Tut' group by ST.staffName order by ST.staffId")
				lab_staff_list=SlotAllocation.find_by_sql("select ST.staffId, ST.staffName from lessons L, slot_allocations SA, staff_assignments STA,staffs ST,subjects S where SA.lessonId=L.lessonId and L.subjectCode=S.subjectCode and SA.groupId=STA.groupId and STA.lessonId=SA.lessonId and STA.staffId=ST.staffId and S.subjectCode='#{sub_list[sa].id}' and L.lessonType='Lab' group by ST.staffName order by ST.staffId")
				
				lec_staff_list_finish=false
				tut_staff_list_finish=false
				lab_staff_list_finish=false
				
				row_no=0
				while (!lec_staff_list_finish || !tut_staff_list_finish || !lab_staff_list_finish)
					if row_no==0
						row=sub_list[sa].id+tab+Subject.find(sub_list[sa].id).subjectName
					else
						row=tab
					end
					
					if lec_staff_list[row_no]!=nil						
						grp_query=SlotAllocation.find_by_sql("select LG.groupIndex from lesson_groups LG,lessons L, slot_allocations SA, staff_assignments STA,staffs ST,subjects S where SA.lessonId=L.lessonId and L.subjectCode=S.subjectCode and SA.groupId=LG.groupId and STA.lessonId=SA.lessonId and STA.groupId=SA.groupId and STA.staffId=ST.staffId and S.subjectCode='#{sub_list[sa].id}' and L.lessonType='Lec' and ST.staffId=#{lec_staff_list[row_no].staffId} group by LG.groupIndex order by LG.groupIndex")
						
						grp_list=""
						hrs=0
						0.upto(grp_query.length-1) do |gq|
							grp_list+=grp_query[gq].groupIndex+","
							s_query=StaffAssignment.find_by_sql("select STA.teachLessonWeek from staff_assignments STA,lessons L, lesson_groups LG where STA.staffId=#{lec_staff_list[row_no].staffId} and L.lessonType='Lec' and L.subjectCode='#{sub_list[sa].id}' and L.lessonId=STA.lessonId and LG.groupIndex='#{grp_query[gq].groupIndex}' and LG.groupId=STA.groupId")
							teachWeek=Array.new
							teachWeek=s_query[0].teachLessonWeek.split(",")
							freq=Lesson.find(:first, :conditions=>"subjectCode='#{sub_list[sa].id}' and lessonType='Lec'").noOfLesson
							teach_hr=teachWeek.length*freq.to_i
							hrs+=teach_hr
						end
						
						if grp_list!=""
							grp_list=grp_list[0,grp_list.length-1]
						end
						row+=tab+lec_staff_list[row_no].staffName+tab+grp_list+tab+hrs.to_s+" ("+grp_query.length.to_s+")"
						
					else
						row+=tab+tab+tab
						lec_staff_list_finish=true
					end
					
					if tut_staff_list[row_no]!=nil						
						grp_query=SlotAllocation.find_by_sql("select LG.groupIndex from lesson_groups LG,lessons L, slot_allocations SA, staff_assignments STA,staffs ST,subjects S where SA.lessonId=L.lessonId and L.subjectCode=S.subjectCode and SA.groupId=LG.groupId and STA.lessonId=SA.lessonId and STA.groupId=SA.groupId and STA.staffId=ST.staffId and S.subjectCode='#{sub_list[sa].id}' and L.lessonType='Tut' and ST.staffId=#{tut_staff_list[row_no].staffId} group by LG.groupIndex order by LG.groupIndex")
						
						grp_list=""
						hrs=0
						0.upto(grp_query.length-1) do |gq|
							grp_list+=grp_query[gq].groupIndex+","
							s_query=StaffAssignment.find_by_sql("select STA.teachLessonWeek from staff_assignments STA,lessons L, lesson_groups LG where STA.staffId=#{tut_staff_list[row_no].staffId} and L.lessonType='Tut' and L.subjectCode='#{sub_list[sa].id}' and L.lessonId=STA.lessonId and LG.groupIndex='#{grp_query[gq].groupIndex}' and LG.groupId=STA.groupId")
							teachWeek=Array.new
							teachWeek=s_query[0].teachLessonWeek.split(",")
							freq=Lesson.find(:first, :conditions=>"subjectCode='#{sub_list[sa].id}' and lessonType='Tut'").noOfLesson
							teach_hr=teachWeek.length*freq.to_i
							hrs+=teach_hr
						end
						
						if grp_list!=""
							grp_list=grp_list[0,grp_list.length-1]
						end
						row+=tab+tut_staff_list[row_no].staffName+tab+grp_list+tab+hrs.to_s+" ("+grp_query.length.to_s+")"
						
					else
						row+=tab+tab+tab
						tut_staff_list_finish=true
					end
					
					if lab_staff_list[row_no]!=nil						
						grp_query=SlotAllocation.find_by_sql("select LG.groupIndex from lesson_groups LG,lessons L, slot_allocations SA, staff_assignments STA,staffs ST,subjects S where SA.lessonId=L.lessonId and L.subjectCode=S.subjectCode and SA.groupId=LG.groupId and STA.lessonId=SA.lessonId and STA.groupId=SA.groupId and STA.staffId=ST.staffId and S.subjectCode='#{sub_list[sa].id}' and L.lessonType='Lab' and ST.staffId=#{lab_staff_list[row_no].staffId} group by LG.groupIndex order by LG.groupIndex")
						
						grp_list=""
						hrs=0
						0.upto(grp_query.length-1) do |gq|
							grp_list+=grp_query[gq].groupIndex+","
							s_query=StaffAssignment.find_by_sql("select STA.teachLessonWeek from staff_assignments STA,lessons L, lesson_groups LG where STA.staffId=#{lab_staff_list[row_no].staffId} and L.lessonType='Lab' and L.subjectCode='#{sub_list[sa].id}' and L.lessonId=STA.lessonId and LG.groupIndex='#{grp_query[gq].groupIndex}' and LG.groupId=STA.groupId")
							teachWeek=Array.new
							teachWeek=s_query[0].teachLessonWeek.split(",")
							freq=Lesson.find(:first, :conditions=>"subjectCode='#{sub_list[sa].id}' and lessonType='Lab'").noOfLesson
							teach_hr=teachWeek.length*freq.to_i*2
							hrs+=teach_hr
						end
						
						if grp_list!=""
							grp_list=grp_list[0,grp_list.length-1]
						end
						row+=tab+lab_staff_list[row_no].staffName+tab+grp_list+tab+hrs.to_s+" ("+grp_query.length.to_s+")"
						
					else
						row+=tab+tab+tab
						lab_staff_list_finish=true
					end
					
					if !lec_staff_list_finish || !tut_staff_list_finish || !lab_staff_list_finish
						sub_grp.puts row
					else
						sub_grp.puts cr
					end
					row_no+=1
					
				end			 
				
			end
			
			sub_grp.close
		end 
		
		render :nothing=>true
	end	
	
	def grp_stat_printout
		if session[:user]==nil
			redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
		end
	end 
	
	def process_grp_stat_printout
		tab="\t"
		cr="\n"
		
		grp_stat=File.new("public/files/GroupStatistics.xls","w")
		
		grp_stat.puts "STUDENT COHORT"+tab+tab+tab+tab+"SUBJECT TITLE"+tab+"LEC GRP"+tab+"TUT GRP"+tab+"LAB GRP"+tab+"REMARK"
		grp_stat.puts	"99-03SC"+tab+"04CS"+tab+"04CE"+tab+"Others"+tab+tab+tab+"(Hr/Wk)"
		
		sub_list=Subject.find(:all,:order=>"subjectCode")
		shared_list=""
		0.upto(sub_list.length-1) do |sa|
			
			same_sub=SharedSubjectCode.find_by_sql("Select * from shared_subject_codes where sharedSubjectCodes like '%#{sub_list[sa].subjectCode}%'")
			
			if same_sub.length==0
				case Subject.find(sub_list[sa].id).discipline
				when "SC"
					row=sub_list[sa].id+tab+"-"+tab+"-"+tab+"-"+tab+Subject.find(sub_list[sa].id).subjectName
				when "CS"
					row="-"+tab+sub_list[sa].id+tab+"-"+tab+"-"+tab+Subject.find(sub_list[sa].id).subjectName
				when "CE"
					row="-"+tab+"-"+tab+sub_list[sa].id+tab+"-"+tab+Subject.find(sub_list[sa].id).subjectName
				else
					row="-"+tab+"-"+tab+"-"+tab+sub_list[sa].id+tab+Subject.find(sub_list[sa].id).subjectName
				end
				
				lec_grp_count=LessonGroup.find_by_sql("SELECT count(distinct LG.groupIndex) as GrpCount FROM lessons L, lesson_groups LG, slot_allocations SA where L.subjectCode='#{sub_list[sa].id}' and L.lessonType='Lec' and L.lessonId=SA.lessonId and SA.groupId=LG.groupId")[0].GrpCount.to_s
				tut_grp_count=LessonGroup.find_by_sql("SELECT count(distinct LG.groupIndex) as GrpCount FROM lessons L, lesson_groups LG, slot_allocations SA where L.subjectCode='#{sub_list[sa].id}' and L.lessonType='Tut' and L.lessonId=SA.lessonId and SA.groupId=LG.groupId")[0].GrpCount.to_s
				lab_grp_count=LessonGroup.find_by_sql("SELECT count(distinct LG.groupIndex) as GrpCount FROM lessons L, lesson_groups LG, slot_allocations SA where L.subjectCode='#{sub_list[sa].id}' and L.lessonType='Lab' and L.lessonId=SA.lessonId and SA.groupId=LG.groupId")[0].GrpCount.to_s
				
				if lec_grp_count=="0"
					lec_grp_count=""
				end
				if tut_grp_count=="0"
					tut_grp_count=""
				end
				if lab_grp_count=="0"
					lab_grp_count=""
				end				
				row+=tab+lec_grp_count+tab+tut_grp_count+tab+lab_grp_count+tab+Subject.find(sub_list[sa].id).remarks	 
				
			else
				sc_lec_grp_count=""
				sc_tut_grp_count=""
				sc_lab_grp_count=""
				cs_lec_grp_count=""
				cs_tut_grp_count=""
				cs_lab_grp_count=""
				ce_lec_grp_count=""
				ce_tut_grp_count=""
				ce_lab_grp_count=""
				others_lec_grp_count=""
				others_tut_grp_count=""
				others_lab_grp_count=""
				sc_id=""
				cs_id=""
				ce_id=""
				others_id=""
				ce_remark=""
				cs_remark=""
				sc_remark=""
				others_remark=""
				
				
				shared_sub=Array.new
				shared_sub=same_sub[0].sharedSubjectCodes.split(",")
				if shared_list.include?(same_sub[0].sharedSubjectCodes)==false
				shared_list+=same_sub[0].sharedSubjectCodes+","
				0.upto(shared_sub.length-1) do |ss|
					
					if Subject.find(shared_sub[ss]).discipline=="SC"
						sc_id=shared_sub[ss]
						sc_lec_grp_count=LessonGroup.find_by_sql("SELECT count(distinct LG.groupIndex) as GrpCount FROM lessons L, lesson_groups LG, slot_allocations SA where L.subjectCode='#{shared_sub[ss]}' and L.lessonType='Lec' and L.lessonId=SA.lessonId and SA.groupId=LG.groupId")[0].GrpCount.to_s
						sc_tut_grp_count=LessonGroup.find_by_sql("SELECT count(distinct LG.groupIndex) as GrpCount FROM lessons L, lesson_groups LG, slot_allocations SA where L.subjectCode='#{shared_sub[ss]}' and L.lessonType='Tut' and L.lessonId=SA.lessonId and SA.groupId=LG.groupId")[0].GrpCount.to_s
						sc_lab_grp_count=LessonGroup.find_by_sql("SELECT count(distinct LG.groupIndex) as GrpCount FROM lessons L, lesson_groups LG, slot_allocations SA where L.subjectCode='#{shared_sub[ss]}' and L.lessonType='Lab' and L.lessonId=SA.lessonId and SA.groupId=LG.groupId")[0].GrpCount.to_s
						sc_remark=Subject.find(shared_sub[ss]).remarks
					end
					
					if Subject.find(shared_sub[ss]).discipline=="CS"
						cs_id=shared_sub[ss]
						cs_lec_grp_count=LessonGroup.find_by_sql("SELECT count(distinct LG.groupIndex) as GrpCount FROM lessons L, lesson_groups LG, slot_allocations SA where L.subjectCode='#{shared_sub[ss]}' and L.lessonType='Lec' and L.lessonId=SA.lessonId and SA.groupId=LG.groupId")[0].GrpCount.to_s
						cs_tut_grp_count=LessonGroup.find_by_sql("SELECT count(distinct LG.groupIndex) as GrpCount FROM lessons L, lesson_groups LG, slot_allocations SA where L.subjectCode='#{shared_sub[ss]}' and L.lessonType='Tut' and L.lessonId=SA.lessonId and SA.groupId=LG.groupId")[0].GrpCount.to_s
						cs_lab_grp_count=LessonGroup.find_by_sql("SELECT count(distinct LG.groupIndex) as GrpCount FROM lessons L, lesson_groups LG, slot_allocations SA where L.subjectCode='#{shared_sub[ss]}' and L.lessonType='Lab' and L.lessonId=SA.lessonId and SA.groupId=LG.groupId")[0].GrpCount.to_s
						cs_remark=Subject.find(shared_sub[ss]).remarks
					end
					
					if Subject.find(shared_sub[ss]).discipline=="CE"
						ce_id=shared_sub[ss]
						ce_lec_grp_count=LessonGroup.find_by_sql("SELECT count(distinct LG.groupIndex) as GrpCount FROM lessons L, lesson_groups LG, slot_allocations SA where L.subjectCode='#{shared_sub[ss]}' and L.lessonType='Lec' and L.lessonId=SA.lessonId and SA.groupId=LG.groupId")[0].GrpCount.to_s
						ce_tut_grp_count=LessonGroup.find_by_sql("SELECT count(distinct LG.groupIndex) as GrpCount FROM lessons L, lesson_groups LG, slot_allocations SA where L.subjectCode='#{shared_sub[ss]}' and L.lessonType='Tut' and L.lessonId=SA.lessonId and SA.groupId=LG.groupId")[0].GrpCount.to_s
						ce_lab_grp_count=LessonGroup.find_by_sql("SELECT count(distinct LG.groupIndex) as GrpCount FROM lessons L, lesson_groups LG, slot_allocations SA where L.subjectCode='#{shared_sub[ss]}' and L.lessonType='Lab' and L.lessonId=SA.lessonId and SA.groupId=LG.groupId")[0].GrpCount.to_s
						ce_remark=Subject.find(shared_sub[ss]).remarks
				 end
					
					if Subject.find(shared_sub[ss]).discipline!="SC" && Subject.find(shared_sub[ss]).discipline!="CS"	&& Subject.find(shared_sub[ss]).discipline!="CE"
						others_id=shared_sub[ss]
						others_lec_grp_count=LessonGroup.find_by_sql("SELECT count(distinct LG.groupIndex) as GrpCount FROM lessons L, lesson_groups LG, slot_allocations SA where L.subjectCode='#{shared_sub[ss]}' and L.lessonType='Lec' and L.lessonId=SA.lessonId and SA.groupId=LG.groupId")[0].GrpCount.to_s
						others_tut_grp_count=LessonGroup.find_by_sql("SELECT count(distinct LG.groupIndex) as GrpCount FROM lessons L, lesson_groups LG, slot_allocations SA where L.subjectCode='#{shared_sub[ss]}' and L.lessonType='Tut' and L.lessonId=SA.lessonId and SA.groupId=LG.groupId")[0].GrpCount.to_s
						others_lab_grp_count=LessonGroup.find_by_sql("SELECT count(distinct LG.groupIndex) as GrpCount FROM lessons L, lesson_groups LG, slot_allocations SA where L.subjectCode='#{shared_sub[ss]}' and L.lessonType='Lab' and L.lessonId=SA.lessonId and SA.groupId=LG.groupId")[0].GrpCount.to_s
						others_remark=Subject.find(shared_sub[ss]).remarks
					end
				end
			end
			
				if sc_id!=""
					row=sc_id
				else
					row="-"
				end
				if cs_id!=""
					row+=tab+cs_id
				else
					row+=tab+"-"
				end
				if ce_id!=""
					row+=tab+ce_id
				else
					row+=tab+"-"
				end
				if others_id!=""
					row+=tab+others_id
				else
					row+=tab+"-"
				end
				
				lec_grp=""
				remark=""
				if sc_lec_grp_count!="0" && sc_lec_grp_count!=""
					lec_grp=sc_lec_grp_count+"+"
					if sc_remark!=""
						remark=sc_remark+"+"
					end
				end
				if cs_lec_grp_count!="0" && cs_lec_grp_count!=""
					lec_grp+=cs_lec_grp_count+"+"
					if cs_remark!=""
						remark+=cs_remark+"+"
					end
				end
				if ce_lec_grp_count!="0" && ce_lec_grp_count!=""
					lec_grp+=ce_lec_grp_count+"+"
					if ce_remark!=""
						remark+=ce_remark+"+"
					end
				end
				if others_lec_grp_count!="0" && others_lec_grp_count!=""
					lec_grp+=others_lec_grp_count+"+"
					if others_remark!=""
						remark+=others_remark+"+"
					end
				end
				if lec_grp!=""
					lec_grp=lec_grp[0,lec_grp.length-1]
				end
				if remark!=""
					remark=remark[0,remark.length-1]
				end
				
				
				tut_grp=""
				if sc_tut_grp_count!="0" && sc_tut_grp_count!=""
					tut_grp=sc_tut_grp_count+"+"
				end
				if cs_tut_grp_count!="0" && cs_tut_grp_count!=""
					tut_grp+=cs_tut_grp_count+"+"
				end
				if ce_tut_grp_count!="0" && ce_tut_grp_count!=""
					tut_grp+=ce_tut_grp_count+"+"
				end
				if others_tut_grp_count!="0" && others_tut_grp_count!=""
					tut_grp+=others_tut_grp_count+"+"
				end
				if tut_grp!=""
					tut_grp=tut_grp[0,tut_grp.length-1]
				end
				
				lab_grp=""
				if sc_lab_grp_count!="0" && sc_lab_grp_count!=""
					lab_grp=sc_lab_grp_count+"+"
				end
				if cs_lab_grp_count!="0" && cs_lab_grp_count!=""
					lab_grp+=cs_lab_grp_count+"+"
				end
				if ce_lab_grp_count!="0" && ce_lab_grp_count!=""
					lab_grp+=ce_lab_grp_count+"+"
				end
				if others_lab_grp_count!="0" && others_lab_grp_count!=""
					lab_grp+=others_lab_grp_count+"+"
				end
				if lab_grp!=""
					lab_grp=lab_grp[0,lab_grp.length-1]
				end
				
				row+=tab+Subject.find(sub_list[sa].id).subjectName+tab+lec_grp+tab+tut_grp+tab+lab_grp+tab+remark
			end
			if sc_id!="" || cs_id!="" || ce_id!="" || others_id!=""	
				grp_stat.puts row
				grp_stat.puts cr
			end
		end
		
		grp_stat.close
		
		render :nothing=>true
	end
	
	def venue_clash_printout
		if session[:user]==nil
			redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
		end		
	end
	
	def process_venue_clash_printout
		
		ven_clash=File.new("public/files/VenueClash.txt","w")
		ven_clash.print "Venue Clash Printout\r\n\r\n"
		
		query=SlotAllocation.find_by_sql("SELECT count(venueName)as noOfClass,venueName,timeSlotId,alloc_lesson_freq as freq FROM slot_allocations group by venueName,timeSlotId,alloc_lesson_freq having noOfClass>1 order by venueName,timeSlotId")
		
		0.upto(query.length-1) do |q|
			
			clash_query=SlotAllocation.find(:all,:conditions=>"venueName='#{query[q].venueName}' and timeSlotId='#{query[q].timeSlotId}'")
			shared_query=SharedSubjectCode.find(:all,:conditions=>"sharedType like '%#{Lesson.find(clash_query[0].lessonId).lessonType}%' and sharedSubjectCodes like '%#{Lesson.find(clash_query[0].lessonId).subjectCode}%'")
			
			check_ok=true
			if shared_query.length==1
				0.upto(clash_query.length-1) do |c|
					if shared_query[0].sharedSubjectCodes.include?(Lesson.find(clash_query[c].lessonId).subjectCode)
						check_ok=false
					else
						check_ok=true
						break
					end
				end
				
			end
			
			if check_ok
				clash_details="VenueName=" +query[q].venueName+" "+TimeSlot.find(query[q].timeSlotId).dayOfWeek.to_s+" "+TimeSlot.find_by_sql("Select Time(startTime)as startT from time_slots where timeSlotId='#{query[q].timeSlotId}'")[0].startT+"-"+TimeSlot.find_by_sql("Select Time(endTime)as endT from time_slots where timeSlotId='#{query[q].timeSlotId}'")[0].endT+"	"+"Freq="+query[q].freq+"\n"
				ven_clash.puts clash_details
				header="========================================================\n"
				header+="SubjectCode"+"	"+"LessonType"+" "+"LessonGroup"+"\n"
				header+="========================================================\n"
				ven_clash.puts header
				info=""
				0.upto(clash_query.length-1) do |c|
				 
					info+=Lesson.find(clash_query[c].lessonId).subjectCode+"				"+Lesson.find(clash_query[c].lessonId).lessonType+"				"+LessonGroup.find(clash_query[c].groupId).groupIndex+"		"+"\n"
				 
				end
				info+="\n"
				ven_clash.puts info
			end
		end
		
		
		ven_clash.close
		render :nothing=>true
	end
	
	def subject_printout
		if session[:user]==nil
			redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
		end
	end
	
	def process_subject_printout
		subExcel=File.new("public/files/subjectPrintout.xls","w")
		tab="\t"
		cr="\n"
		
		subExcel.puts "SubjectCode" + tab + "SubjectName" + tab + "YearOfStudy"+tab+"discipline"+tab+"acad_unit"+tab+"cohort size"+tab+"Remark"+cr
		query=Subject.find_by_sql("SELECT * from subjects")
		
		0.upto(query.length-1) do |q|
			contents=query[q].subjectCode+tab+query[q].subjectName+tab+query[q].yearOfStudy+tab+query[q].discipline+tab+query[q].acad_unit.to_s+tab+query[q].cohort_size.to_s+tab+query[q].remarks+cr
			subExcel.puts contents
		end
		
		subExcel.close
		render :nothing=>true
	end
	
	def subject_list_printout
	end
	
	def process_subject_list_printout
		subExcel=File.new("public/files/subjectListPrintout.xls","w")
		tab="\t"
		cr="\n"
		
		subExcel.puts "SubjectListName" + tab + "SubjectCode" +cr
		query=Subject.find_by_sql("SELECT * from subject_lists order by subjectListName")
		subListName=""
		subcode=""
		0.upto(query.length-1) do |q|
			
				if query[q].subjectListName==subListName
					subcode+=","+query[q].subjectCode
				else
					if subListName!=""
						contents=subListName+tab+subcode+cr
						subExcel.puts contents
					end
					subListName=query[q].subjectListName
					subcode=query[q].subjectCode
				end
			
			
			#contents=query[q].subjectCode+tab+query[q].subjectName+tab+query[q].yearOfStudy+tab+query[q].discipline+tab+query[q].acad_unit.to_s+tab+query[q].cohort_size.to_s+tab+query[q].remarks+cr
			#subExcel.puts contents
		end
		
		subExcel.close
		render :nothing=>true
	end
	
end
