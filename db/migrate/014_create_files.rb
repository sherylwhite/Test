class CreateFiles < ActiveRecord::Migration
  def self.up
  end

  def self.down
    drop_table :files
  end
end
