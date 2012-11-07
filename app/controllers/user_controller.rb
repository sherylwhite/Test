class UserController < ApplicationController
  layout 'standard'
  
  def user
      if session[:user]==nil
      redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
    else      
      @user_list=Login.find(:all,:order=>"userName")
      @msg=params[:msg]
    end
  end
  
  def process_user
    action=params[:actionDDM]
    user_id=params[:userListDDM]
    user_type=params[:userTypeDDM]
    user_name=params[:userName]
    pwd=params[:pwd]
    email=params[:email]
    msg=0
    if action=="Register"
      user_exist=Login.find_by_sql("Select * from logins where userName='#{user_name}'")
      if user_exist.length>0
        msg=1
      else
        user=Login.new
        user.userName=user_name
        user.accType=user_type
        user.password=pwd
        user.email=email
        user.save
        msg=2
      end
      
    elsif action=="Update"
      user=Login.find(user_id)
      user.update_attribute :accType, user_type
      user.update_attribute :userName,user_name
      user.update_attribute :email, email
      msg=3
    else
      user=Login.find(user_id)
      Login.delete(user)
      msg=4
    end
    redirect_to :action=>"user", :msg=>msg
  end
  
  
end
