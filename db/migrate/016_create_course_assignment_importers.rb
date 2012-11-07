class CreateCourseAssignmentImporters < ActiveRecord::Migration
  def self.ups
  end

  def self.down
    drop_table :course_assignment_importers
  end
end
