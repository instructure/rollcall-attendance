# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20140512213941)
class AddSourceToJobs < ActiveRecord::Migration[4.2]
  def connection
    Delayed::Job.connection
  end

  def up
    add_column :delayed_jobs, :source, :string
    add_column :failed_jobs, :source, :string
  end

  def down
    remove_column :delayed_jobs, :source
    remove_column :failed_jobs, :source
  end
end
