# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20210928174754)
class FixSingletonConditionInBeforeInsert < ActiveRecord::Migration[5.2]
  def change
    reversible do |direction|
      direction.up do
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
              -- this condition seems silly, but it forces postgres to use the two partial indexes on singleton,
              -- rather than doing a seq scan
              PERFORM 1 FROM delayed_jobs WHERE singleton = NEW.singleton AND (locked_by IS NULL OR locked_by IS NOT NULL);
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
    end
  end
end
