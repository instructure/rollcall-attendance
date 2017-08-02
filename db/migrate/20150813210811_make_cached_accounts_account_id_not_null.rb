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

class MakeCachedAccountsAccountIdNotNull < ActiveRecord::Migration
  def up
    CachedAccount.where(account_id: nil).destroy_all
    change_column :cached_accounts, :account_id, :integer, :limit => 8, :null => false
  end

  def down
    change_column :cached_accounts, :account_id, :integer, :limit => 8, :null => true
  end
end
