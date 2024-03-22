# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20110516225834)
class AddDelayedJobsStrand < ActiveRecord::Migration[4.2]
  def connection
    Delayed::Backend::ActiveRecord::Job.connection
  end

  def up
    add_column :delayed_jobs, :strand, :string
    add_index :delayed_jobs, :strand
  end

  def down
    remove_column :delayed_jobs, :strand
  end
end
