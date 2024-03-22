# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20110426161613)
class AddDelayedJobsMaxAttempts < ActiveRecord::Migration[4.2]
  def connection
    Delayed::Backend::ActiveRecord::Job.connection
  end

  def up
    add_column :delayed_jobs, :max_attempts, :integer
  end

  def down
    remove_column :delayed_jobs, :max_attempts
  end
end
