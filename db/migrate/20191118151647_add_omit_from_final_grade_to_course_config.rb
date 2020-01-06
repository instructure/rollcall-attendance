#
# Copyright (C) 2019 - present Instructure, Inc.
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

class AddOmitFromFinalGradeToCourseConfig < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    if ActiveRecord::ConnectionAdapters.const_defined?("Mysql2Adapter") && ActiveRecord::Base.connection.instance_of?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
      add_column :course_configs, :omit_from_final_grade, :boolean, default: false, null: false
    else
      add_column :course_configs, :omit_from_final_grade, :boolean
      change_column_default :course_configs, :omit_from_final_grade, false
      DataFixup::BackfillNulls.run(CourseConfig, :omit_from_final_grade, new_value: false, batch_size: 1000)
      change_column_null(:course_configs, :omit_from_final_grade, false)
    end
  end

  def down
    remove_column :course_configs, :omit_from_final_grade
  end
end
