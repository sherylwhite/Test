class CreateSharedSubjectCodes < ActiveRecord::Migration
  def self.up
  end

  def self.down
    drop_table :shared_subject_codes
  end
end
