class CreateStaffAssignments < ActiveRecord::Migration
  def self.up
  end

  def self.down
    drop_table :staff_assignments
  end
end
