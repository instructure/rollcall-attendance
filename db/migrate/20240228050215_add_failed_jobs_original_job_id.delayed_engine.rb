# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20140505215131)
class AddFailedJobsOriginalJobId < ActiveRecord::Migration[4.2]
  def connection
    Delayed::Backend::ActiveRecord::Job.connection
  end

  def up
    add_column :failed_jobs, :original_job_id, :integer, limit: 8
  end

  def down
    remove_column :failed_jobs, :original_job_id
  end
end
