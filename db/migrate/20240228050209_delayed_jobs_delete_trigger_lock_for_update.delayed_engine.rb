# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20120510004759)
class DelayedJobsDeleteTriggerLockForUpdate < ActiveRecord::Migration[4.2]
  def connection
    Delayed::Backend::ActiveRecord::Job.connection
  end

  def up
    execute(<<~SQL)
      CREATE OR REPLACE FUNCTION delayed_jobs_after_delete_row_tr_fn () RETURNS trigger AS $$
      BEGIN
        UPDATE delayed_jobs SET next_in_strand = 't' WHERE id = (SELECT id FROM delayed_jobs j2 WHERE j2.strand = OLD.strand ORDER BY j2.strand, j2.id ASC LIMIT 1 FOR UPDATE);
        RETURN OLD;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  def down
    execute(<<~SQL)
      CREATE OR REPLACE FUNCTION delayed_jobs_after_delete_row_tr_fn () RETURNS trigger AS $$
      BEGIN
        UPDATE delayed_jobs SET next_in_strand = 't' WHERE id = (SELECT id FROM delayed_jobs j2 WHERE j2.strand = OLD.strand ORDER BY j2.strand, j2.id ASC LIMIT 1);
        RETURN OLD;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end
end
