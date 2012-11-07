class Staff2Controller < ApplicationController
	before_filter :login_required
	include Staff2Helper
	layout 'standard'
	
	def import_status
		@percent_complete = MiddleMan.worker(:staff2_worker, 'import_staff2').ask_result(:percent_complete)
		if request.xhr?
			if @percent_complete >= 100
				render :update do |page|
					flash[:notice] = "Importing is completed!"
					MiddleMan.worker(:staff2_worker, 'import_staff2').delete
					page.redirect_to :action=>"import_staff"
				end
			else
				render :update do |page|
					page[:workingStatus].setStyle :width => "#{@percent_complete*4}px"
					page[:workingStatus].replace_html "#{@percent_complete}%"
				end
			end
		end
	end
	def stop_worker
		MiddleMan.worker(:staff2_worker, 'import_staff2').delete
		render :text=>"worker stopped"
	end
	def upload_staff
		Files.saveStaff2(params["staffup"])
#		excel_init("public/files/SubjectGroup.xls");
#		import
#		redirect_to :action=> "import_staff"
#		return
	end
	def import_staff_step1
		if !(params["skip"])
			Staff.delete_all "staffId!=0"
		else
			redirect_to :action=> "import_staff_step2"
		end
	end
	def import_staff_step2
		MiddleMan.new_worker(:worker => :staff2_worker, :worker_key => 'import_staff2')
		redirect_to :action=> "import_status"
	end
	def export_staff
		write_staff_list
	end

	# import back an exported staff list to database
	def import_exported_list
		if (request.post?)
			Files.save_to_public(params["file_staff_list"], "staff_list.xls")
			import_exported("public/files/staff_list.xls")
		end
	end
end
