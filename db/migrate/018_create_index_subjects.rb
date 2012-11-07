class CreateIndexSubjects < ActiveRecord::Migration
  def self.up
    create_table :index_subjects do |t|
    end
  end

  def self.down
    drop_table :index_subjects
  end
end
