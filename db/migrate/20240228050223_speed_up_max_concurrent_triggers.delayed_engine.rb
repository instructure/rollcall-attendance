# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20181217155351)
class SpeedUpMaxConcurrentTriggers < ActiveRecord::Migration[4.2]
  def connection
    Delayed::Job.connection
  end

  def up
    # tl;dr sacrifice some responsiveness to max_concurrent changes for faster performance
    # don't get the count every single time - it's usually safe to just set the next one in line
    # since the max_concurrent doesn't change all that often for a strand
    execute(<<~SQL)
      CREATE OR REPLACE FUNCTION delayed_jobs_after_delete_row_tr_fn () RETURNS trigger AS $$
      DECLARE
        running_count integer;
      BEGIN
        IF OLD.strand IS NOT NULL THEN
          PERFORM pg_advisory_xact_lock(half_md5_as_bigint(OLD.strand));
          IF OLD.id % 20 = 0 THEN
            running_count := (SELECT COUNT(*) FROM (
              SELECT 1 as one FROM delayed_jobs WHERE strand = OLD.strand AND next_in_strand = 't' LIMIT OLD.max_concurrent
            ) subquery_for_count);
            IF running_count < OLD.max_concurrent THEN
              UPDATE delayed_jobs SET next_in_strand = 't' WHERE id IN (
                SELECT id FROM delayed_jobs j2 WHERE next_in_strand = 'f' AND
                j2.strand = OLD.strand ORDER BY j2.id ASC LIMIT (OLD.max_concurrent - running_count) FOR UPDATE
              );
            END IF;
          ELSE
            UPDATE delayed_jobs SET next_in_strand = 't' WHERE id =
              (SELECT id FROM delayed_jobs j2 WHERE next_in_strand = 'f' AND
                j2.strand = OLD.strand ORDER BY j2.id ASC LIMIT 1 FOR UPDATE);
          END IF;
        END IF;
        RETURN OLD;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    # don't need the full count on insert
    execute(<<~SQL)
      CREATE OR REPLACE FUNCTION delayed_jobs_before_insert_row_tr_fn () RETURNS trigger AS $$
      BEGIN
        IF NEW.strand IS NOT NULL THEN
          PERFORM pg_advisory_xact_lock(half_md5_as_bigint(NEW.strand));
          IF (SELECT COUNT(*) FROM (
              SELECT 1 AS one FROM delayed_jobs WHERE strand = NEW.strand LIMIT NEW.max_concurrent
            ) subquery_for_count) = NEW.max_concurrent THEN
            NEW.next_in_strand := 'f';
          END IF;
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  def down
    execute(<<~SQL)
      CREATE OR REPLACE FUNCTION delayed_jobs_after_delete_row_tr_fn () RETURNS trigger AS $$
      DECLARE
        running_count integer;
      BEGIN
        IF OLD.strand IS NOT NULL THEN
          PERFORM pg_advisory_xact_lock(half_md5_as_bigint(OLD.strand));
          running_count := (SELECT COUNT(*) FROM delayed_jobs WHERE strand = OLD.strand AND next_in_strand = 't');
          IF running_count < OLD.max_concurrent THEN
            UPDATE delayed_jobs SET next_in_strand = 't' WHERE id IN (
              SELECT id FROM delayed_jobs j2 WHERE next_in_strand = 'f' AND
              j2.strand = OLD.strand ORDER BY j2.id ASC LIMIT (OLD.max_concurrent - running_count) FOR UPDATE
            );
          END IF;
        END IF;
        RETURN OLD;
      END;
      $$ LANGUAGE plpgsql;
    SQL

    execute(<<~SQL)
      CREATE OR REPLACE FUNCTION delayed_jobs_before_insert_row_tr_fn () RETURNS trigger AS $$
      BEGIN
        IF NEW.strand IS NOT NULL THEN
          PERFORM pg_advisory_xact_lock(half_md5_as_bigint(NEW.strand));
          IF (SELECT COUNT(*) FROM delayed_jobs WHERE strand = NEW.strand) >= NEW.max_concurrent THEN
            NEW.next_in_strand := 'f';
          END IF;
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end
end
