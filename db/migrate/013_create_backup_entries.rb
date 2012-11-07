class CreateBackupEntries < ActiveRecord::Migration
  def self.up
  end

  def self.down
    drop_table :backup_entries
  end
end
