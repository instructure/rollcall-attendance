# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20210929204903)
class UpdateConflictingSingletonFunctionToUseIndex < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      CREATE OR REPLACE FUNCTION delayed_jobs_before_unlock_delete_conflicting_singletons_row_fn () RETURNS trigger AS $$
      BEGIN
        DELETE FROM delayed_jobs WHERE id<>OLD.id AND singleton=OLD.singleton AND locked_by IS NULL;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end

  def down
    execute(<<~SQL)
      CREATE OR REPLACE FUNCTION delayed_jobs_before_unlock_delete_conflicting_singletons_row_fn () RETURNS trigger AS $$
      BEGIN
        IF EXISTS (SELECT 1 FROM delayed_jobs j2 WHERE j2.singleton=OLD.singleton) THEN
          DELETE FROM delayed_jobs WHERE id<>OLD.id AND singleton=OLD.singleton;
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL
  end
end
