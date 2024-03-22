# frozen_string_literal: true

# This migration comes from delayed_engine (originally 20210917232626)
class AddDeleteConflictingSingletonsBeforeUnlockTrigger < ActiveRecord::Migration[5.2]
  def up
    execute(<<~SQL)
      CREATE FUNCTION delayed_jobs_before_unlock_delete_conflicting_singletons_row_fn () RETURNS trigger AS $$
      BEGIN
        IF EXISTS (SELECT 1 FROM delayed_jobs j2 WHERE j2.singleton=OLD.singleton) THEN
          DELETE FROM delayed_jobs WHERE id<>OLD.id AND singleton=OLD.singleton;
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    SQL
    execute(<<~SQL)
      CREATE TRIGGER delayed_jobs_before_unlock_delete_conflicting_singletons_row_tr BEFORE UPDATE ON delayed_jobs FOR EACH ROW WHEN (
        OLD.singleton IS NOT NULL AND
        OLD.singleton=NEW.singleton AND
        OLD.locked_by IS NOT NULL AND
        NEW.locked_by IS NULL) EXECUTE PROCEDURE delayed_jobs_before_unlock_delete_conflicting_singletons_row_fn();
    SQL
  end

  def down
    execute("DROP FUNCTION delayed_jobs_before_unlock_delete_conflicting_singletons_row_tr_fn()")
  end
end
