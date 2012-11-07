class CreateClashExceptions < ActiveRecord::Migration
  def self.up
  end

  def self.down
    drop_table :clash_exceptions
  end
end
