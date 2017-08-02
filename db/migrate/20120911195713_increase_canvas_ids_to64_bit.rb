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

class IncreaseCanvasIdsTo64Bit < ActiveRecord::Migration
  def up
    change_column :awards, :course_id, :integer, limit: 8
    change_column :awards, :student_id, :integer, limit: 8
    change_column :badges, :course_id, :integer, limit: 8
    change_column :canvas_authorizations, :canvas_user_id, :integer, limit:  8
    change_column :course_configs, :course_id, :integer, limit: 8
    change_column :launches, :account_id, :integer, limit: 8
    change_column :launches, :course_id, :integer, limit: 8
    change_column :launches, :user_id, :integer, limit: 8
    change_column :seating_charts, :course_id, :integer, limit: 8
    change_column :seating_charts, :section_id, :integer, limit: 8
    change_column :statuses, :account_id, :integer, limit: 8
    change_column :statuses, :course_id, :integer, limit: 8
    change_column :statuses, :section_id, :integer, limit: 8
    change_column :statuses, :student_id, :integer, limit: 8
  end

  def down
    change_column :awards, :course_id, :integer
    change_column :awards, :student_id, :integer
    change_column :badges, :course_id, :integer
    change_column :canvas_authorizations, :canvas_user_id, :integer
    change_column :course_configs, :course_id, :integer
    change_column :launches, :account_id, :integer
    change_column :launches, :course_id, :integer
    change_column :launches, :user_id, :integer
    change_column :seating_charts, :course_id, :integer
    change_column :seating_charts, :section_id, :integer
    change_column :statuses, :account_id, :integer
    change_column :statuses, :course_id, :integer
    change_column :statuses, :section_id, :integer
    change_column :statuses, :student_id, :integer
  end
end
