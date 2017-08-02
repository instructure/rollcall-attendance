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

class CreateAwards < ActiveRecord::Migration
  def change
    create_table :awards do |t|
      t.integer :student_id
      t.integer :course_id
      t.integer :badge_id
      t.date :class_date

      t.timestamps
    end

    add_index :awards, [:student_id, :course_id, :class_date]
    add_index :awards, [:student_id, :course_id, :class_date, :badge_id], unique: true, name: 'unique_award'
  end
end
