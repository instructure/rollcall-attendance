class RemoveUniqueIndexFromStatuses < ActiveRecord::Migration[5.2]
  def change
    remove_index :statuses, [:student_id, :section_id, :class_date, :tool_consumer_instance_guid, :course_id]
  end
end
