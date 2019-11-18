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
      # Look at https://dev.mysql.com/doc/refman/5.6/en/innodb-online-ddl-operations.html#online-ddl-column-operations
      # for some additional information. We're trying to do the database changes in place without needing a copy table,
      # the MySQL default. We're on a new enough MySQL that we should be able to the add the column, set the default,
      # and set it NOT NULL all without a copy nor a lock.
      execute <<~SQL
        ALTER TABLE course_configs
        ADD COLUMN omit_from_final_grade BOOL DEFAULT false NOT NULL,
        ALGORITHM=INPLACE,
        LOCK=NONE;
      SQL
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
