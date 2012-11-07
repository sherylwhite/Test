class CreateLessons < ActiveRecord::Migration
  def self.up
  end

  def self.down
    drop_table :lessons
  end
end
