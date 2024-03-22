# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20120608191051)
class AddJobsRunAtIndex < ActiveRecord::Migration[4.2]
  disable_ddl_transaction! if respond_to?(:disable_ddl_transaction!)

  def connection
    Delayed::Backend::ActiveRecord::Job.connection
  end

  def up
    add_index :delayed_jobs, %w[run_at tag], algorithm: :concurrently
  end

  def down
    remove_index :delayed_jobs, name: "index_delayed_jobs_on_run_at_and_tag"
  end
end
