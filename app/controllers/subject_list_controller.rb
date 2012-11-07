class SubjectListController < ApplicationController
  layout 'standard'
  
  def subject_list
    if session[:user]==nil
      redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
    else
      @sublist_list=SubjectList.find_by_sql("Select Distinct subjectListName from subject_lists order by subjectListName")
      @sub_list=Subject.find(:all, :order=>"subjectCode")
      @msg=params[:msg]
    end
  end
  
  def process_subject_list
    action=params[:actionDDM]
    sub_list_name=params[:subjectListName].strip
    sub_sel=params[:inListSubjectDDM]
    
    msg=0
    
    if action=="Add"      
      sub_list_exist=SubjectList.find_by_sql("Select Distinct subjectListName from subject_lists where subjectListName='#{sub_list_name}'")
        if sub_list_exist.length>0
          # ADD error, subject list name already exists
          msg=1
        else
          0.upto(sub_sel.length-1) do |ss|
            sl=SubjectList.new
            sl.subjectListName=sub_list_name
            sl.subjectCode=sub_sel[ss]
            sl.save
          end
          #ADD ok!
          msg=2
        end
        
    elsif action=="Update"
      sub_list_query=SubjectList.find(:all, :conditions=>"subjectListName='#{sub_list_name}'", :order=>"subjectCode")
      
      0.upto(sub_list_query.length-1) do |sl|
        sub_exist=false
        
        0.upto(sub_sel.length-1) do |ss|
          if sub_list_query[sl].subjectCode==sub_sel[ss]
            sub_exist=true
          end          
        end  
        
        if sub_exist==false
            SubjectList.delete(sub_list_query[sl].subjectListId)
        end
        
      end
      
      sub_list_query=SubjectList.find(:all, :conditions=>"subjectListName='#{sub_list_name}'", :order=>"subjectCode")
      
      0.upto(sub_sel.length-1) do |ss|
        sub_exist=false
        
        0.upto(sub_list_query.length-1) do |sl|
          if sub_sel[ss]==sub_list_query[sl].subjectCode
            sub_exist=true
          end          
        end  
        
        if sub_exist==false
            sl=SubjectList.new
            sl.subjectListName=sub_list_name
            sl.subjectCode=sub_sel[ss]
            sl.save
        end        
      end
            
      #UPDATE ok!
      msg="3"
    else
      sub_list_query=SubjectList.find(:all, :conditions=>"subjectListName='#{sub_list_name}'")
      
      0.upto(sub_list_query.length-1) do |sl|        
       SubjectList.delete(sub_list_query[sl].subjectListId)           
      end
      #DELETE ok!
      msg=4
    end
      redirect_to :action=>"subject_list", :msg=>msg
      
  
  end
  
end
