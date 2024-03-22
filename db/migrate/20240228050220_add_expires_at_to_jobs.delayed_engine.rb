# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20151123210429)
class AddExpiresAtToJobs < ActiveRecord::Migration[4.2]
  def connection
    Delayed::Job.connection
  end

  def up
    add_column :delayed_jobs, :expires_at, :datetime
    add_column :failed_jobs, :expires_at, :datetime
  end

  def down
    remove_column :delayed_jobs, :expires_at
    remove_column :failed_jobs, :expires_at
  end
end
