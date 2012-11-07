# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_tps_session_id'
  def login_required
    if session[:user]
      return true
    else
      redirect_to :controller=>'tps', :action=>'login', :msg=>'PleaseLogin'
      return false
    end
  end
  
  def _dbg(msg)
    if (true)
      puts msg
    end
  end
end
