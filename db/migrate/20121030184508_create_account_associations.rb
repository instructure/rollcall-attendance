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

class CreateAccountAssociations < ActiveRecord::Migration[4.2]
  def change
    create_table :account_associations do |t|
      t.integer :account_id
      t.integer :descendant_id
      t.timestamps
    end

    create_table :accounts do |t|
      t.integer :parent_id
      t.timestamp :last_sync_on
      t.timestamps
    end
  end
end
