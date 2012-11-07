class Files < ActiveRecord::Base
  def self.save(upload)
    name = "latestSTARS.txt"
    directory = "public/files"
    path = File.join(directory,name)
    File.open(path,"wb") { |f| f.write(upload.read) }
  end
  
  def self.saveSub(upload)
    name = "MODsubjectDetails.xls"
    directory = "public/files"
    path = File.join(directory,name)
    File.open(path,"wb") { |f| f.write(upload.read) }
  end
  
  def self.saveGrp(upload)
    name = "MODlessonGroupDetails.xls"
    directory = "public/files"
    path = File.join(directory,name)
    File.open(path,"wb") { |f| f.write(upload.read) }
  end
  
  def self.saveVen(upload)
    name = "MODvenueDetails.xls"
    directory = "public/files"
    path = File.join(directory,name)
    File.open(path,"wb") { |f| f.write(upload.read) }
  end
  
  def self.saveStaff(upload)
    name = "StaffDetails.xls"
    directory = "public/files"
    path = File.join(directory,name)
    File.open(path,"wb") { |f| f.write(upload.read) }
  end
   
  def self.saveStaff2(upload)
    name = "SubjectGroup.xls"
    directory = "public/files"
    path = File.join(directory,name)
    File.open(path,"wb") { |f| f.write(upload.read) }
  end
  
  def self.save_to_public(upload, path)
  	path = File.join("public/files", path)
  	File.open(path, "wb") { |f| f.write(upload.read) }
  end
end
