class CreateVenues < ActiveRecord::Migration
  def self.up
  end

  def self.down
    drop_table :venues
  end
end
