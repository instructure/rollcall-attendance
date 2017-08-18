#
# Copyright (C) 2014 - present Instructure, Inc.
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

class ReaddIndexesToIncludeTciGuid < ActiveRecord::Migration[4.2]
  def change
    add_index :statuses, [:student_id, :tool_consumer_instance_guid]
    add_index :statuses, [:section_id, :class_date, :tool_consumer_instance_guid],
      name: 'index_statuses_on_section_date_tciguid'
    add_index :statuses, [:student_id, :section_id, :class_date, :tool_consumer_instance_guid], unique: true,
      name: 'index_statuses_uniquely'
    add_index :course_configs, [:course_id, :tool_consumer_instance_guid], unique: true,
      name: 'index_course_configs, uniquely'
    add_index :awards, [:student_id, :course_id, :class_date, :tool_consumer_instance_guid],
      name: 'index_awards_on_course_student_date_tciguid'
    add_index :awards, [:student_id, :course_id, :class_date, :badge_id, :tool_consumer_instance_guid], unique: true,
      name: 'index_awards_uniquely'
    add_index :statuses, [:course_id, :tool_consumer_instance_guid]
    add_index :statuses, [:account_id, :tool_consumer_instance_guid]
    add_index :awards, [:course_id, :class_date, :tool_consumer_instance_guid],
      name: 'index_awards_on_course_date_tciguid'
    add_index :badges, [:account_id, :tool_consumer_instance_guid]
    add_index :badges, [:course_id, :tool_consumer_instance_guid]
    add_index :seating_charts, [:section_id, :class_date, :tool_consumer_instance_guid],
      name: 'index_seating_charts_on_section_date_tciguid'
  end
end
