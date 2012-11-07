require 'spreadsheet'
module Staff2Helper
	# import the data from excel file to database
	def import
		subject_regions = recognize_course()
		# go through each region iteratively.
		0.upto(subject_regions.size - 2) do |current_region|
			logger.info subject_regions[current_region]
			process_region(subject_regions[current_region], subject_regions[current_region+1])
		end
	end

	# startup procedures, recognize some special information	
	def excel_init(path_to_excel_file)
		Spreadsheet.client_encoding = 'UTF-8'
		# open the excel file for reading
		timetable = Spreadsheet.open path_to_excel_file
		# open the target excel tab 'course assignment'
		@assignment = timetable.worksheet 0
		# identify the sheet information
		dim = @assignment.dimensions
		@first_row = dim[0]
		@last_row = dim[1]
		@first_col = dim[2]
		@last_col = dim[3]
		logger.info "#{@first_row}-#{@last_row}-#{@first_col}-#{@last_col}"
		# index of the columns that have specific information
		# and column sign which can help us to recognize them	
		@subject_col = 0;	subject_text = 'SUBJECT'
		@lec_col = 0;		lec_text = 'LECTURE'
		@tut_col = 0;		tut_text = 'TUTORIAL'
		@lab_col = 0;		lab_text = 'LABORATORY'
		@subject_row = 0;
		@indexes = 4
		
		catch "FoundRealFirstRow" do
			@first_row.upto(@last_row) do |rid|
				@first_col.upto(@last_col) do |cid|
					if !(@assignment.cell(rid, cid).nil?)
						@first_row = rid
						throw "FoundRealFirstRow"
					end
				end
			end
		end
		catch "FoundRealLastRow" do
			@last_row.downto(@first_row) do |rid|
				@first_col.upto(@last_col) do |cid|
					if !(@assignment.cell(rid, cid).nil?)
						@last_row = rid
						throw "FoundRealLastRow"
					end
				end
			end
		end
		# need to identify the indexes first
		count_col = 0
		catch "FoundAllHeaders" do
			@first_row.upto(@last_row) do |rid|
				@first_col.upto(@last_col) do |cid|
					# is_found: the content of the cell is match with the header
					is_found = true
					case @assignment.cell(rid, cid)
						when subject_text then
							 @subject_col = cid
							 @subject_row = rid
						when lec_text then @lec_col = cid
						when tut_text then @tut_col = cid
						when lab_text then @lab_col = cid
						else is_found = false
					end
					if (is_found) 
						count_col = count_col + 1
					end
					# break the loop if we found all the indexes
					throw "FoundAllHeaders" if (count_col == @indexes)
				end
			end
		end
	end

	# an excel file is divided into many courses, each course is often offered for 2 semesters this
	# function will count the number of semesters (which are the regions to be investigated later on)
	def recognize_course
		# ignore one row for title of column
		current_subject_row = @subject_row + 1
		course_regions = []
		current_cell_value = ''
		# dividing the region for the subjects by using semester columns
		while (current_subject_row < @last_row) do
			current_subject_row += 1
			current_cell_value = @assignment.cell(current_subject_row, @subject_col)
			# ignore nil cell
			if (current_cell_value.nil?)
				next
			end
			# got something different :), remember the row index of this region
			course_regions.push(current_subject_row)
		end
		return course_regions
	end


	# top and bottom determine the region of a subject
	# return value is array of course information in following format
	# {
	#	 :code => ['CSC102','CPE102'],
	#	 :name => 'Intro to Programming',
	#	 :staff => [
	#							 { name				=> 'Hui Siu Cheung',
	#								 designation => ['LEC','TUT'],
	#								 group			 => ['FS1','FS2'],
	#								 teachWeek	 => '1 to 7'
	#							 },...
	#						 ]
	# }
	def process_region(top, bottom)
		# code & name
	 	code = @assignment.cell(top, @subject_col)
	 	name = @assignment.cell(top, @subject_col + 1)

		#check whether we are having information about this course?
		begin
			Subject.find(code)
		rescue
# subject code is not in reference_subjects record
#			rs = Subject.new
#			rs.id = subject_code
#			rs.subjectName = 'TEST'
#			rs.yearOfStudy = 3
#			rs.discipline = 'SCE'
#			rs.acad_unit = 4
#			rs.cohort_size = 30
#			rs.remarks = 'remark'
#			rs.save
			return code
		end
	 	# lecture
	 	#-- lecture group seem to be only one
	 	lec_groups = [@assignment.cell(top, @lec_col)]
	 	#-- lecture staffs, can be more than one
	 	lec_staffs = []
	 	current_row = top
		while !(current_staff = @assignment.cell(current_row, @lec_col+1)).nil? do
			lec_staffs.push current_staff
			current_row += 1
		end
		#-- find out whether this course is taught on ODD weeks, EVEN weeks, All weeks or ABNORMAL 
	 	current_row = top
	 	lec_weeks = []
		while !(current_weeks = @assignment.cell(current_row, @lec_col+2)).nil? do
			lec_weeks.push current_weeks 
			current_row += 1
		end
		if !(lec_groups[0].nil?)
			commit_to_database(code, name, "LEC", lec_staffs, lec_groups, lec_weeks)
		end
		
		
		# tutorial
	 	#-- tutorial might form more than 1 group
	 	tut_groups = []
	 	current_row = top
		while !(current_grp = @assignment.cell(current_row, @tut_col)).nil? do
			tut_groups.push current_grp
			current_row += 1
		end
	 	#-- tutors, can be more than one
	 	tut_staffs = []
	 	current_row = top
		while !(current_staff = @assignment.cell(current_row, @tut_col+1)).nil? do
			tut_staffs.push current_staff
			current_row += 1
		end
		#-- find out whether this course is taught on ODD weeks, EVEN weeks, All weeks or ABNORMAL 
	 	current_row = top
	 	tut_weeks = []
		while !(current_weeks = @assignment.cell(current_row, @tut_col+2)).nil? do
			tut_weeks.push current_weeks 
			current_row += 1
		end
		commit_to_database(code, name, "TUT", tut_staffs, tut_groups, tut_weeks)
		
		# lab
	 	#-- lab might form more than 1 group
	 	lab_groups = []
	 	current_row = top
		while !(current_grp = @assignment.cell(current_row, @lab_col)).nil? do
			lab_groups.push current_grp
			current_row += 1
		end
	 	#-- tutors, can be more than one
	 	lab_staffs = []
	 	current_row = top
		while !(current_staff = @assignment.cell(current_row, @lab_col+1)).nil? do
			lab_staffs.push current_staff
			current_row += 1
		end
		#-- find out whether this course is taught on ODD weeks, EVEN weeks, All weeks or ABNORMAL 
	 	current_row = top
	 	lab_weeks = []
		while !(current_weeks = @assignment.cell(current_row, @lab_col+2)).nil? do
			lab_weeks.push current_weeks 
			current_row += 1
		end	
		commit_to_database(code, name, "LAB", lab_staffs, lab_groups, lab_weeks)
	end

	def commit_to_database(code, name, type, staffs, groups, weeks)
		# process group
		if (groups.size ==0)
			return
		end
		
		for groupIndex in groups
			group = LessonGroup.find_by_groupIndex(groupIndex)
			if (group.nil?)
				group = LessonGroup.new
				group.groupIndex = groupIndex
			end
			
			# example "CSC303" -> ["CSC", "303"]
			group_split = groupIndex.scan(/([A-Z]+)(\d+)/).map[0]
			if not group_split.nil?
				group.groupPrefix = group_split[0]
				group.groupNo = group_split[1]
			else
				group.groupPrefix = group.groupId
				group.groupNo = 0
			end
	 
			# type of lesson
			# get the group size base on type of lesson
			case type
				when "LEC" then group.groupSize = 120
				when "TUT" then group.groupSize = 35
				else group.groupSize = 35
			end
		 
			# save record to database
			# TODO handle database error
			group.save
		end
		
		# number of lesson, depend on type of lesson
			case type
			when "LEC" then number_of_lesson = 3
			when "TUT" then number_of_lesson = 1
			else number_of_lesson = 1
		end
		
		weeks_str = weeks.join(",")
		# list of week having this lesson
		# weeks_str: ["1", "2", "3", ...]
		is_freq_odd = true
		is_freq_even = true
			freq = "WEEKLY"
		
		1.upto(13) do |w|
			if (w%2 == 0 && weeks_str.include?(w.to_s))
				is_freq_odd = false
			end
			if (w%2 == 1 && weeks_str.include?(w.to_s))
				is_freq_even = false
			end
			freq = "ALTERN" unless weeks_str.include?(w.to_s)
		end
		
		alloc_freq = "WEEKLY"
		if is_freq_odd
				alloc_freq = "ODD"
		elsif is_freq_even
				alloc_freq = "EVEN"
		end

		# lesson table
		lesson = Lesson.find_by_subjectCode_and_lessonType(code, type)
	 		if lesson.nil?
			# insert new record
			lesson = Lesson.new
			lesson.subjectCode = code
			lesson.lessonType = type
			lesson.noOfLesson = number_of_lesson
			lesson.frequency = freq
			lesson.lessonGroupsAssigned = groups.join(",")
			# FIXME report to professor, this information is not included inside the resource
			lesson.possibleVenues = ""
			lesson.save
		else
			# only need to update frequency & lessonGroupsAssigned
			lesson.update_attribute :frequency, freq
			# update assigned groups
			group_assigned =	lesson.lessonGroupsAssigned
			for group in groups
				group_assigned += ",#{group}" unless group_assigned.include?(group)
			end
			lesson.update_attribute :lessonGroupsAssigned, group_assigned
		end
		
		# Staff Assigned
		# for each group
		0.upto(staffs.size-1) do |id|
			staff_assignment = StaffAssignment.find_by_groupId_and_lessonId(group, lesson.lessonId)
			if staff_assignment.nil?
				staff_assignment = StaffAssignment.new
				# search for group Id by groupIndex
				group = nil
				if type == "LEC"
					group = LessonGroup.find_by_groupIndex(groups[0])
				else
					group = LessonGroup.find_by_groupIndex(groups[id])
				end
			end
			# search for staff_id in staffs table
			staff = Staff.find_by_staffName(staffs[id])
			if (staff.nil?) 
				staff = Staff.new
				staff.staffName = staffs[id]
				staff.designation = type
				staff.save
			elsif !(staff.designation.include?(type))
				if (staff.designation.empty?)
					staff.update_attribute :designation, (type)
				else
					staff.update_attribute :designation, (staff.designation + "," + type)
				end
			end
			staffId = staff.staffId;
		
			staff_assignment.groupId = group.groupId
			staff_assignment.lessonId = lesson.lessonId
			staff_assignment.staffId = staffId
			staff_assignment.teachLessonWeek = weeks[id]
			staff_assignment.save
		end
		# slot allocation FIXME not working since venue is not in here
#		day_of_week = {
#			"M"	=>	"Monday",
#			"T" =>	"Tuesday",
#			"W"	=>	"Wednesday",
#			"TH"=>	"Thursday",
#			"F"	=>	"Friday",
#			"S" =>	"Saturday"
#		}
		
		# FIXME for testing purpose only
		lesson_conduct_day = "Monday" #day_of_week[lesson_conduct_day]
		lesson_start_time = "21:30"
		lesson_end_time = "22:30"
	 		for groupIndex in groups
			while (lesson_start_time < lesson_end_time)
				time_slot_id = TimeSlot.find_by_startTime_and_dayOfWeek(lesson_start_time,lesson_conduct_day).timeSlotId
				sa = SlotAllocation.new
				sa.lessonId = lesson.lessonId
				sa.groupId = LessonGroup.find_by_groupIndex(groupIndex).groupId
				# FIXME
				sa.venueName = "UNKNOWN"
				sa.timeSlotId = time_slot_id
				sa.alloc_lesson_freq = alloc_freq
				sa.lessonWeek = weeks_str
				sa.save
				# next slot please
				temp = lesson_start_time[0,2].to_i+1
				if temp.to_s.length == 1
					temp = "0" + temp.to_s
				end
				lesson_start_time = temp.to_s + ":30"
			end
		end
	end
	
	def write_staff_list
		book = Spreadsheet::Workbook.new
		sheet_staff = book.create_worksheet :name => 'Staff list'
		staffs = Staff.find(:all, :order => 'staffName')
		
		sheet_staff[0,0] = "Name"
		sheet_staff[0,1] = "Division"
		sheet_staff[0,2] = "School"
		sheet_staff[0,3] = "Email"
		sheet_staff[0,4] = "Room"
		sheet_staff[0,5] = "Number"		
		1.upto(staffs.size) do |row|
			sheet_staff[row, 0] = staffs[row-1].staffName.upcase
			sheet_staff[row, 1] = staffs[row-1].division.empty? ? "N/A" : staffs[row-1].division
			sheet_staff[row, 2] = staffs[row-1].school.empty? ? "Unknown" : staffs[row-1].school
			sheet_staff[row, 3] = staffs[row-1].email.empty? ? "Unknown" : staffs[row-1].email
			sheet_staff[row, 4] = staffs[row-1].roomNo.empty? ? "Unknown" : staffs[row-1].roomNo
			sheet_staff[row, 5] = staffs[row-1].extNo.empty? ? "Unknown" : staffs[row-1].extNo
		end
		sheet_staff.column(0).width = 30
		downloadLink = 'public/files/StaffList.xls'
		book.write downloadLink
		send_file(downloadLink)
	end
	
	def import_exported(path_to_excel_file)
		Spreadsheet.client_encoding = 'UTF-8'
		# open the excel file for reading
		timetable = Spreadsheet.open path_to_excel_file
		# open the target excel tab 'course assignment'
		assignment = timetable.worksheet 0
		number_of_rows = assignment.dimensions[1]
		
		1.upto(number_of_rows-1) do |row|
			staff_name = assignment.cell(row, 0)
			staff = Staff.find_by_staffName(staff_name)
			if (staff.nil?)
				staff = Staff.new
				staff.staffName = staff_name
			end
			staff.division = assignment.cell(row, 1) == "N/A" ? "" : assignment.cell(row, 1)
			staff.school = assignment.cell(row, 2) == "Unknown" ? "" : assignment.cell(row, 2)
			staff.email = assignment.cell(row, 3) == "Unknown" ? "" : assignment.cell(row, 3)
			staff.roomNo = assignment.cell(row, 4) == "Unknown" ? "" : assignment.cell(row, 4)
			staff.extNo = assignment.cell(row, 5) == "Unknown" ? "" : assignment.cell(row, 5)
			
			staff.save
		end
	end
end