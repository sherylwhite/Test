class CreateLessonGroups < ActiveRecord::Migration
  def self.up
  end

  def self.down
    drop_table :lesson_groups
  end
end
