# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20210812210128)
class AddSingletonColumn < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_column :delayed_jobs, :singleton, :string, if_not_exists: true
    add_column :failed_jobs, :singleton, :string, if_not_exists: true
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

    reversible do |direction|
      direction.up do
        execute(<<~SQL)
          CREATE OR REPLACE FUNCTION delayed_jobs_after_delete_row_tr_fn () RETURNS trigger AS $$
          DECLARE
            running_count integer;
            should_lock boolean;
            should_be_precise boolean;
            update_query varchar;
            skip_locked varchar;
          BEGIN
            IF OLD.strand IS NOT NULL THEN
              should_lock := true;
              should_be_precise := OLD.id % (OLD.max_concurrent * 4) = 0;

              IF NOT should_be_precise AND OLD.max_concurrent > 16 THEN
                running_count := (SELECT COUNT(*) FROM (
                  SELECT 1 as one FROM delayed_jobs WHERE strand = OLD.strand AND next_in_strand = 't' LIMIT OLD.max_concurrent
                ) subquery_for_count);
                should_lock := running_count < OLD.max_concurrent;
              END IF;

              IF should_lock THEN
                PERFORM pg_advisory_xact_lock(half_md5_as_bigint(OLD.strand));
              END IF;

              -- note that we don't really care if the row we're deleting has a singleton, or if it even
              -- matches the row(s) we're going to update. we just need to make sure that whatever
              -- singleton we grab isn't already running (which is a simple existence check, since
              -- the unique indexes ensure there is at most one singleton running, and one queued)
              update_query := 'UPDATE delayed_jobs SET next_in_strand=true WHERE id IN (
                SELECT id FROM delayed_jobs j2
                  WHERE next_in_strand=false AND
                    j2.strand=$1.strand AND
                    (j2.singleton IS NULL OR NOT EXISTS (SELECT 1 FROM delayed_jobs j3 WHERE j3.singleton=j2.singleton AND j3.id<>j2.id))
                  ORDER BY j2.strand_order_override ASC, j2.id ASC
                  LIMIT ';

              IF should_be_precise THEN
                running_count := (SELECT COUNT(*) FROM (
                  SELECT 1 FROM delayed_jobs WHERE strand = OLD.strand AND next_in_strand = 't' LIMIT OLD.max_concurrent
                ) s);
                IF running_count < OLD.max_concurrent THEN
                  update_query := update_query || '($1.max_concurrent - $2)';
                ELSE
                  -- we have too many running already; just bail
                  RETURN OLD;
                END IF;
              ELSE
                update_query := update_query || '1';

                -- n-strands don't require precise ordering; we can make this query more performant
                IF OLD.max_concurrent > 1 THEN
                  skip_locked := ' SKIP LOCKED';
                END IF;
              END IF;

              update_query := update_query || ' FOR UPDATE' || COALESCE(skip_locked, '') || ')';
              EXECUTE update_query USING OLD, running_count;
            ELSIF OLD.singleton IS NOT NULL THEN
              UPDATE delayed_jobs SET next_in_strand = 't' WHERE singleton=OLD.singleton AND next_in_strand=false;
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
              IF (SELECT COUNT(*) FROM (
                  SELECT 1 FROM delayed_jobs WHERE strand = NEW.strand AND next_in_strand=true LIMIT NEW.max_concurrent
                ) s) = NEW.max_concurrent THEN
                NEW.next_in_strand := false;
              END IF;
            END IF;
            IF NEW.singleton IS NOT NULL THEN
              PERFORM 1 FROM delayed_jobs WHERE singleton = NEW.singleton;
              IF FOUND THEN
                NEW.next_in_strand := false;
              END IF;
            END IF;
            RETURN NEW;
          END;
          $$ LANGUAGE plpgsql;
        SQL
      end
      direction.down do
        execute(<<~SQL)
          CREATE OR REPLACE FUNCTION delayed_jobs_after_delete_row_tr_fn () RETURNS trigger AS $$
          DECLARE
            running_count integer;
            should_lock boolean;
            should_be_precise boolean;
          BEGIN
            IF OLD.strand IS NOT NULL THEN
              should_lock := true;
              should_be_precise := OLD.id % (OLD.max_concurrent * 4) = 0;

              IF NOT should_be_precise AND OLD.max_concurrent > 16 THEN
                running_count := (SELECT COUNT(*) FROM (
                  SELECT 1 as one FROM delayed_jobs WHERE strand = OLD.strand AND next_in_strand = 't' LIMIT OLD.max_concurrent
                ) subquery_for_count);
                should_lock := running_count < OLD.max_concurrent;
              END IF;

              IF should_lock THEN
                PERFORM pg_advisory_xact_lock(half_md5_as_bigint(OLD.strand));
              END IF;

              IF should_be_precise THEN
                running_count := (SELECT COUNT(*) FROM (
                  SELECT 1 as one FROM delayed_jobs WHERE strand = OLD.strand AND next_in_strand = 't' LIMIT OLD.max_concurrent
                ) subquery_for_count);
                IF running_count < OLD.max_concurrent THEN
                  UPDATE delayed_jobs SET next_in_strand = 't' WHERE id IN (
                    SELECT id FROM delayed_jobs j2 WHERE next_in_strand = 'f' AND
                    j2.strand = OLD.strand ORDER BY j2.strand_order_override ASC, j2.id ASC LIMIT (OLD.max_concurrent - running_count) FOR UPDATE
                  );
                END IF;
              ELSE
                -- n-strands don't require precise ordering; we can make this query more performant
                IF OLD.max_concurrent > 1 THEN
                  UPDATE delayed_jobs SET next_in_strand = 't' WHERE id =
                  (SELECT id FROM delayed_jobs j2 WHERE next_in_strand = 'f' AND
                    j2.strand = OLD.strand ORDER BY j2.strand_order_override ASC, j2.id ASC LIMIT 1 FOR UPDATE SKIP LOCKED);
                ELSE
                  UPDATE delayed_jobs SET next_in_strand = 't' WHERE id =
                    (SELECT id FROM delayed_jobs j2 WHERE next_in_strand = 'f' AND
                      j2.strand = OLD.strand ORDER BY j2.strand_order_override ASC, j2.id ASC LIMIT 1 FOR UPDATE);
                END IF;
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
    end

    connection.transaction do
      reversible do |direction|
        direction.up do
          drop_triggers
          execute("CREATE TRIGGER delayed_jobs_before_insert_row_tr BEFORE INSERT ON delayed_jobs FOR EACH ROW WHEN (NEW.strand IS NOT NULL OR NEW.singleton IS NOT NULL) EXECUTE PROCEDURE delayed_jobs_before_insert_row_tr_fn()")
          execute("CREATE TRIGGER delayed_jobs_after_delete_row_tr AFTER DELETE ON delayed_jobs FOR EACH ROW WHEN ((OLD.strand IS NOT NULL OR OLD.singleton IS NOT NULL) AND OLD.next_in_strand=true) EXECUTE PROCEDURE delayed_jobs_after_delete_row_tr_fn()")
        end
        direction.down do
          drop_triggers
          execute("CREATE TRIGGER delayed_jobs_before_insert_row_tr BEFORE INSERT ON delayed_jobs FOR EACH ROW WHEN (NEW.strand IS NOT NULL) EXECUTE PROCEDURE delayed_jobs_before_insert_row_tr_fn()")
          execute("CREATE TRIGGER delayed_jobs_after_delete_row_tr AFTER DELETE ON delayed_jobs FOR EACH ROW WHEN (OLD.strand IS NOT NULL AND OLD.next_in_strand = 't') EXECUTE PROCEDURE delayed_jobs_after_delete_row_tr_fn()")
        end
      end
    end
  end

  def drop_triggers
    execute("DROP TRIGGER delayed_jobs_before_insert_row_tr ON delayed_jobs")
    execute("DROP TRIGGER delayed_jobs_after_delete_row_tr ON delayed_jobs")
  end
end
