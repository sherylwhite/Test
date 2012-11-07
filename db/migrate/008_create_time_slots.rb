class CreateTimeSlots < ActiveRecord::Migration
  def self.up
  end

  def self.down
    drop_table :time_slots
  end
end
