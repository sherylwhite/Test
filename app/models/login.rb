class Login < ActiveRecord::Base
  set_primary_key "userId" 
  
  def password=(value)
    write_attribute("password",Digest::SHA1.hexdigest(value))
  end
  
  def self.authenticate(userName,password)
    find(:first,:conditions=>["userName =? and password = ?",userName,Digest::SHA1.hexdigest(password)])
  end
  
end
