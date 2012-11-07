class StaffController < ApplicationController
  before_filter :login_required
  
  include StaffHelper
  layout 'standard'
  
  def staff
    @staff_list=Staff.find(:all, :conditions=>"staffId!=0",:order=>"staffName")
    @msg=params[:msg]
  end
  
  def process_staff
    action=params[:actionDDM]
    staff_id=params[:staffListDDM]
    staff_name=params[:staffName].upcase
    lecturer=params[:designationBoxLec]
    tutor=params[:designationBoxTut]
    labsup=params[:designationBoxLab]
    division=params[:division]
    school=params[:school]
    email=params[:email]
    room_no=params[:roomNo]
    ext_no=params[:extNo]
    subject_assigned=params[:subjectAssigned]
    remarks=params[:remarks]
    
    designation=""
    
    if lecturer!=nil
      designation="Lec,"
    end
    if tutor!=nil
      designation+="Tut,"
    end
    if labsup!=nil
      designation+="Lab,"
    end
    
    if designation!=""
      designation=designation[0,designation.length-1]
    end
    
    
    msg=0
    
    if action=="Add"      
      staff_exist=Staff.find_by_sql("Select * from staffs where staffName='#{staff_name}'")
        if staff_exist.length>0
          # ADD error, venue name already exists
          msg=1
        else
          staff = Staff.new
          staff.staffName=staff_name
          staff.designation=designation
          staff.division=division
          staff.school=school
          staff.email=email
          staff.roomNo=room_no
          staff.extNo=ext_no
          staff.subjectAssigned=subject_assigned
          staff.remarks=remarks
          staff.save
          msg=2
        end
        
    elsif action=="Update"
      staff_query=Staff.find(staff_id)
      staff_query.update_attribute :staffName,staff_name
      staff_query.update_attribute :designation,designation
      staff_query.update_attribute :division,division
      staff_query.update_attribute :school,school
      staff_query.update_attribute :email,email
      staff_query.update_attribute :roomNo, room_no
      staff_query.update_attribute :extNo, ext_no
      staff_query.update_attribute :subjectAssigned, subject_assigned
      staff_query.update_attribute :remarks, remarks
      msg="3"
    else
      Staff.delete(staff_id)
      msg=4
    end
      redirect_to :action=>"staff", :msg=>msg
  end
  
  def edit_subject_assigned
    sub_assigned=params[:subAssigned]
    
    @sub_list=Subject.find(:all, :order=>"subjectCode")
       
    if sub_assigned==nil
      @got_list=false
    else
      sub_assigned_arr=Array.new
      sub_assigned_arr=sub_assigned.split(",")
      
      query_string=""
      0.upto(sub_assigned_arr.length-1) do |sa|
        query_string+="subjectCode='"+sub_assigned_arr[sa]+"' or "
      end
    
      query_string=query_string[0,query_string.length-3]
      @got_list=true
      @sub_assigned_list=Subject.find_by_sql("Select * from subjects where ( #{query_string} )")
    end
      
    render :layout=>false
  end
  
  def import_status
    @percent_complete = MiddleMan.worker(:tps_worker, 'import_to_db').ask_result(:percent_complete)
    if request.xhr?
      if @percent_complete >= 100
        render :update do |page|
          flash[:notice] = "Importing is completed!"
          MiddleMan.worker(:tps_worker, 'import_to_db').delete
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
    MiddleMan.worker(:tps_worker, 'import_to_db').delete
    render :text=>"worker stopped"
  end
  def upload_staff
    Files.saveStaff(@params["staffup"])
    ActiveRecord::Base.connection.execute("Alter table staffs AUTO_INCREMENT=1")
    MiddleMan.new_worker(:worker => :tps_worker, :worker_key => 'import_to_db')
    redirect_to :action=> "import_status"
 end
  
end
