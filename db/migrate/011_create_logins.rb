class CreateLogins < ActiveRecord::Migration
  def self.up
  end

  def self.down
    drop_table :logins
  end
end
