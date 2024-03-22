# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20220519204546)
class AddRequeuedJobIdToFailedJobs < ActiveRecord::Migration[6.0]
  def change
    add_column :failed_jobs, :requeued_job_id, :integer, limit: 8
  end
end
