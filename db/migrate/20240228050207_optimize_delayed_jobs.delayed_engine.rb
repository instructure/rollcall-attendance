# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20110610213249)
class OptimizeDelayedJobs < ActiveRecord::Migration[4.2]
  def connection
    Delayed::Backend::ActiveRecord::Job.connection
  end

  def up
    create_table :failed_jobs do |t|
      t.integer  "priority",    default: 0
      t.integer  "attempts",    default: 0
      t.string   "handler",     limit: 512_000
      t.integer  "original_id", limit: 8
      t.text     "last_error"
      t.string   "queue"
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string   "locked_by"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "tag"
      t.integer  "max_attempts"
      t.string   "strand"
    end

    remove_index :delayed_jobs, name: "get_delayed_jobs_index"
    remove_index :delayed_jobs, [:strand]

    add_index :delayed_jobs, %w[run_at queue locked_at strand priority], name: "index_delayed_jobs_for_get_next"
    add_index :delayed_jobs, %w[strand id], name: "index_delayed_jobs_on_strand"

    # move all failed jobs to the new failed table
    Delayed::Backend::ActiveRecord::Job.where.not(failed_at: nil).find_each do |job|
      job.fail! unless job.on_hold?
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
