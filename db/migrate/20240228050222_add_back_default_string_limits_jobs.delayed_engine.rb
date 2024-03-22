# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20161206323555)
class AddBackDefaultStringLimitsJobs < ActiveRecord::Migration[4.2]
  def connection
    Delayed::Job.connection
  end

  def up
    drop_triggers

    add_string_limit_if_missing :delayed_jobs, :queue
    add_string_limit_if_missing :delayed_jobs, :locked_by
    add_string_limit_if_missing :delayed_jobs, :tag
    add_string_limit_if_missing :delayed_jobs, :strand
    add_string_limit_if_missing :delayed_jobs, :source

    add_string_limit_if_missing :failed_jobs, :queue
    add_string_limit_if_missing :failed_jobs, :locked_by
    add_string_limit_if_missing :failed_jobs, :tag
    add_string_limit_if_missing :failed_jobs, :strand
    add_string_limit_if_missing :failed_jobs, :source

    readd_triggers
  end

  def drop_triggers
    execute %(DROP TRIGGER delayed_jobs_before_insert_row_tr ON delayed_jobs)
    execute %(DROP TRIGGER delayed_jobs_after_delete_row_tr ON delayed_jobs)
  end

  def readd_triggers
    execute("CREATE TRIGGER delayed_jobs_before_insert_row_tr BEFORE INSERT ON delayed_jobs FOR EACH ROW WHEN (NEW.strand IS NOT NULL) EXECUTE PROCEDURE delayed_jobs_before_insert_row_tr_fn()")
    execute("CREATE TRIGGER delayed_jobs_after_delete_row_tr AFTER DELETE ON delayed_jobs FOR EACH ROW WHEN (OLD.strand IS NOT NULL AND OLD.next_in_strand = 't') EXECUTE PROCEDURE delayed_jobs_after_delete_row_tr_fn()")
  end

  def add_string_limit_if_missing(table, column)
    return if column_exists?(table, column, :string, limit: 255)

    change_column table, column, :string, limit: 255
  end
end
