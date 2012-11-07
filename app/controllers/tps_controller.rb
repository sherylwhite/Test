class TpsController < ApplicationController
  
  def home
    if session[:user]==nil
      redirect_to :action=>'login', :msg=>'PleaseLogin'
    end
  end

  def top
    @win_option=params[:winOption]
  end
  
  def welcome
  end
  
  def login
    @msg=params[:msg]
  end  
  
  def process_login
    
    if session[:user]=Login.authenticate(params[:userName],params[:password])
      redirect_to :action=>'home'
    else
      redirect_to :action=>'login', :msg=>'Failed'
    end
    
  end
  
  def logout
    reset_session
    redirect_to :action=>'login', :msg=>'Logout'
  end
  
end
