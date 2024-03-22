# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20140505223637)
class DropFailedJobsOriginalId < ActiveRecord::Migration[4.2]
  def connection
    Delayed::Backend::ActiveRecord::Job.connection
  end

  def up
    remove_column :failed_jobs, :original_id
  end

  def down
    add_column :failed_jobs, :original_id, :integer, limit: 8
  end
end
