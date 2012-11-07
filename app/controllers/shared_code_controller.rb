class SharedCodeController < ApplicationController
  layout 'standard'
  
  def shared_code
    if session[:user]==nil
      redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
    else
      @shared_list=SharedSubjectCode.find_by_sql("SELECT concat(sharedSubjectName,' (',sharedSubjectCodes,') ' ,' - ',sharedType) as sharedInfo,sharedSubjectName,sharedType,sharedSubjectCodes,remarks FROM shared_subject_codes order by sharedInfo")
      @msg=params[:msg]
    end
  end
  
  def edit_shared_subject_codes
    search_name=params[:searchSubName]
    @sub_list=Subject.find_by_sql("SELECT * FROM subjects where subjectName not in (Select SharedSubjectName from shared_subject_codes) and subjectName like '%#{search_name}%' order by subjectCode")
    @shared_codes=params[:sharedCodes]
    
    if @shared_codes==nil
      @got_list=false
    else
      shared_codes_arr=Array.new
      shared_codes_arr=@shared_codes.split(",")
      
      query_string=""
      0.upto(shared_codes_arr.length-1) do |sc|
        query_string+="subjectCode='"+shared_codes_arr[sc]+"' or "
      end
    
      query_string=query_string[0,query_string.length-3]
      @got_list=true
      @shared_codes_list=Subject.find_by_sql("Select * from subjects where ( #{query_string} )")
    end
    
    render :layout=>false
  end
  
  def process_shared_subject_codes
    action=params[:actionDDM]
    shared_info=params[:sharedSubCodeListDDM]
    shared_name=params[:sharedSubjectName].strip
    shared_codes=params[:sharedSubCodes]
    shared_lec=params[:sharedLec]
    shared_tut=params[:sharedTut]
    shared_lab=params[:sharedLab]
    remarks=params[:remarks].strip
    shared_type=""
    if shared_lec!=nil
      shared_type+="Lec,"
    end
    if shared_tut!=nil
      shared_type+="Tut,"
    end
    if shared_lab!=nil
      shared_type+="Lab,"
    end
    
    shared_type=shared_type[0,shared_type.length-1]
    msg=0
    
    if action=="Add"      
      shared_exist=SharedSubjectCode.find_by_sql("Select * from shared_subject_codes where sharedSubjectName='#{shared_name}'")
        if shared_exist.length>0
          # ADD error, venue name already exists
          msg=1
        else
          shared=SharedSubjectCode.new
          shared.sharedSubjectName=shared_name
          shared.sharedSubjectCodes=shared_codes
          shared.sharedType=shared_type
          shared.remarks=remarks
          shared.save
          #ADD ok!
          msg=2
        end
        
    elsif action=="Update"
      shared_code_query=SharedSubjectCode.find(:first,:conditions=>"concat(sharedSubjectName,' (',sharedSubjectCodes,') ' ,' - ',sharedType) ='#{shared_info}'")
      
      shared_code_query.update_attribute :sharedSubjectName,shared_name
      shared_code_query.update_attribute :sharedSubjectCodes,shared_codes
      shared_code_query.update_attribute :sharedType,shared_type
      shared_code_query.update_attribute :remarks, remarks
      #UPDATE ok!
      msg="3"
    else
      shared_code_query=SharedSubjectCode.find(:first,:conditions=>"concat(sharedSubjectName,' (',sharedSubjectCodes,') ' ,' - ',sharedType) ='#{shared_info}'")
      SharedSubjectCode.delete(shared_code_query.id)
      
      #DELETE ok!
      msg=4
    end
      redirect_to :action=>"shared_code", :msg=>msg
    
  end
  
end
