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

class DropAccountAssociations < ActiveRecord::Migration[4.2]
  def up
    drop_table :account_associations
  end

  def down
    create_table :account_associations do |t|
      t.integer  :account_id
      t.integer  :descendant_id
      t.string   :tool_consumer_instance_guid
      t.timestamps
    end
  end
end
