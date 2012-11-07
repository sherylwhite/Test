class RefSubjectsController < ApplicationController
    layout 'standard'
    
    def ref_subject
      if session[:user]==nil
        redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
      else
        @msg=params[:msg]
        @sub_list=ReferenceSubjects.find(:all, :order=>"subjectCode")
      end
    end
    
    def process_subject
      action=params[:actionDDM]
      sub_code=params[:subjectCode].upcase
      sub_name=params[:subjectName]
      yos=params[:yearOfStudy]
      disc=params[:discipline]
      au=params[:acadUnit]
      cohort=params[:sizeOfCohort]
      remarks=params[:remarks]
    
      msg=0
      if action=="Add"      
      sub_exist=ReferenceSubjects.find_by_sql("Select * from subjects where subjectCode ='#{sub_code}'")
        if sub_exist.length>0
          # ADD error, venue name already exists
          msg=1
        else
          sub=ReferenceSubjects.new
          sub.id=sub_code
          sub.subjectName=sub_name
          sub.yearOfStudy=yos
          sub.discipline=disc
          sub.acad_unit=au
          sub.cohort_size=cohort
          sub.remarks=remarks
          sub.save
          #ADD ok!
          msg=2
        end
        
      elsif action=="Update"
        sub_query=ReferenceSubjects.find(sub_code)
        sub_query.update_attribute :subjectCode, sub_code
        sub_query.update_attribute :subjectName, sub_name
        sub_query.update_attribute :yearOfStudy, yos
        sub_query.update_attribute :discipline, disc
        sub_query.update_attribute :acad_unit, au
        sub_query.update_attribute :cohort_size, cohort
        sub_query.update_attribute :remarks, remarks
        #UPDATE ok!
      msg="3"
      else
        ReferenceSubjects.delete(sub_code)
        #DELETE ok!
        msg=4
      end
      redirect_to :action=>"ref_subject", :msg=>msg    
    end
    
end
