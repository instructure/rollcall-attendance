#
# Copyright (C) 2021 - present Instructure, Inc.
#
# This file is part of Rollcall.
#
# Rollcall is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Rollcall is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.

class UpdateUniqueIndexToStatuses < ActiveRecord::Migration[5.2]
  def up
    remove_index :statuses, [:student_id, :section_id, :class_date, :tool_consumer_instance_guid]
    add_index :statuses, [:student_id, :section_id, :class_date, :tool_consumer_instance_guid, :course_id], unique: true,
      name: 'index_statuses_uniquely'
  end

  def down
    remove_index :statuses, [:student_id, :section_id, :class_date, :tool_consumer_instance_guid, :course_id]
    add_index :statuses, [:student_id, :section_id, :class_date, :tool_consumer_instance_guid], unique: true,
      name: 'index_statuses_uniquely'
  end
end
