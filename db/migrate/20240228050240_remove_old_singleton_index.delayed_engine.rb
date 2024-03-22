# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20220203063200)
class RemoveOldSingletonIndex < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    remove_index :delayed_jobs, name: "index_delayed_jobs_on_singleton_not_running_old"
    remove_index :delayed_jobs, name: "index_delayed_jobs_on_singleton_running_old"
  end

  def down
    rename_index :delayed_jobs, "index_delayed_jobs_on_singleton_not_running", "index_delayed_jobs_on_singleton_not_running_old"
    rename_index :delayed_jobs, "index_delayed_jobs_on_singleton_running", "index_delayed_jobs_on_singleton_running_old"

    # only one job can be queued in a singleton
    add_index :delayed_jobs,
              :singleton,
              where: "singleton IS NOT NULL AND locked_by IS NULL",
              unique: true,
              name: "index_delayed_jobs_on_singleton_not_running",
              algorithm: :concurrently

    # only one job can be running for a singleton
    add_index :delayed_jobs,
              :singleton,
              where: "singleton IS NOT NULL AND locked_by IS NOT NULL",
              unique: true,
              name: "index_delayed_jobs_on_singleton_running",
              algorithm: :concurrently
  end
end
