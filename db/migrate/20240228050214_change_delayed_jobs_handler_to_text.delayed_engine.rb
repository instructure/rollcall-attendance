# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20120927184213)
class ChangeDelayedJobsHandlerToText < ActiveRecord::Migration[4.2]
  def connection
    Delayed::Job.connection
  end

  def up
    change_column :delayed_jobs, :handler, :text
  end

  def down
    change_column :delayed_jobs, :handler, :string, limit: 500.kilobytes
  end
end
