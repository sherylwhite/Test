class CreateReferenceSubjects < ActiveRecord::Migration
  def self.up
  end

  def self.down
    drop_table :reference_subjects
  end
end
