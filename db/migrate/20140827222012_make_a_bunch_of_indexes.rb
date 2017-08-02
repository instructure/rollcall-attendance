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

class MakeABunchOfIndexes < ActiveRecord::Migration
  def up
    add_index :account_associations, :account_id
    add_index :account_associations, :descendant_id

    add_index :awards, [:course_id, :class_date]

    add_index :badges, :account_id
    add_index :badges, :course_id

    add_index :lti_provider_launches, [:nonce, :created_at]

    add_index :seating_charts, [:section_id, :class_date]
  end

  def down
    remove_index :account_associations, :account_id
    remove_index :account_associations, :descendant_id

    remove_index :awards, [:course_id, :class_date]

    remove_index :badges, :account_id
    remove_index :badges, :course_id

    remove_index :lti_provider_launches, [:nonce, :created_at]

    remove_index :seating_charts, [:section_id, :class_date]
  end
end
