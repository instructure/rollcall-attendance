# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20190726154743)
class MakeCriticalColumnsNotNull < ActiveRecord::Migration[4.2]
  def connection
    Delayed::Job.connection
  end

  def up
    change_column_null :delayed_jobs, :run_at, false
    change_column_null :delayed_jobs, :queue, false
  end

  def down
    change_column_null :delayed_jobs, :run_at, true
    change_column_null :delayed_jobs, :queue, true
  end
end
