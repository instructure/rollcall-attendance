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

class RemoveNonTciGuidIndexes < ActiveRecord::Migration
  def up
    remove_index :statuses, :student_id
    remove_index :statuses, [:section_id, :class_date]
    remove_index :statuses, [:student_id, :section_id, :class_date]
    remove_index :course_configs, :course_id
    remove_index :awards, [:student_id, :course_id, :class_date]
    remove_index :awards, name: 'unique_award'
    remove_index :statuses, :course_id
    remove_index :statuses, :account_id
    remove_index :awards, [:course_id, :class_date]
    remove_index :badges, :account_id
    remove_index :badges, :course_id
    remove_index :seating_charts, [:section_id, :class_date]
  end

  def down
    add_index :statuses, :student_id
    add_index :statuses, [:section_id, :class_date]
    add_index :statuses, [:student_id, :section_id, :class_date], unique: true
    add_index :course_configs, :course_id, unique: true
    add_index :awards, [:student_id, :course_id, :class_date]
    add_index :awards, [:student_id, :course_id, :class_date, :badge_id], unique: true, name: 'unique_award'
    add_index :statuses, :course_id
    add_index :statuses, :account_id
    add_index :awards, [:course_id, :class_date]
    add_index :badges, :account_id
    add_index :badges, :course_id
    add_index :seating_charts, [:section_id, :class_date]
  end
end
