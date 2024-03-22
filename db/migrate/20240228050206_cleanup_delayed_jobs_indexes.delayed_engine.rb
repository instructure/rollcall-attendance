# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20110531144916)
class CleanupDelayedJobsIndexes < ActiveRecord::Migration[4.2]
  def connection
    Delayed::Backend::ActiveRecord::Job.connection
  end

  def up
    # "nulls first" syntax is postgresql specific, and allows for more
    # efficient querying for the next job
    connection.execute("CREATE INDEX get_delayed_jobs_index ON delayed_jobs (priority, run_at, failed_at nulls first, locked_at nulls first, queue)")

    # unused indexes
    remove_index :delayed_jobs, name: "delayed_jobs_queue"
    remove_index :delayed_jobs, name: "delayed_jobs_priority"
  end

  def down
    remove_index :delayed_jobs, name: "get_delayed_jobs_index"
    add_index :delayed_jobs, %i[priority run_at], name: "delayed_jobs_priority"
    add_index :delayed_jobs, [:queue], name: "delayed_jobs_queue"
  end
end
