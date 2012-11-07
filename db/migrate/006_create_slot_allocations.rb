class CreateSlotAllocations < ActiveRecord::Migration
  def self.up
  end

  def self.down
    drop_table :slot_allocations
  end
end
