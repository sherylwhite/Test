class CreateStaffs < ActiveRecord::Migration
  def self.up
  end

  def self.down
    drop_table :staffs
  end
end
