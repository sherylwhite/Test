class CreateSubjectLists < ActiveRecord::Migration
  def self.up
  end

  def self.down
    drop_table :subject_lists
  end
end
