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

class AddToolConsumerInstanceGuid < ActiveRecord::Migration[4.2]
  def change
    add_column :awards, :tool_consumer_instance_guid, :string
    add_column :badges, :tool_consumer_instance_guid, :string
    add_column :course_configs, :tool_consumer_instance_guid, :string
    add_column :seating_charts, :tool_consumer_instance_guid, :string
    add_column :statuses, :tool_consumer_instance_guid, :string
    add_column :accounts, :tool_consumer_instance_guid, :string
    add_column :account_associations, :tool_consumer_instance_guid, :string
  end
end
