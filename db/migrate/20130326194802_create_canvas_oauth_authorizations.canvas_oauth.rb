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
#
# This migration comes from canvas_oauth (originally 20121121005358)
class CreateCanvasOauthAuthorizations < ActiveRecord::Migration
  def change
    rename_table :canvas_authorizations, :canvas_oauth_authorizations
    # This is the original migration from the CanvasOauth gem but we
    # have opted for renaming the existing table rather than dropping it and
    # recreating it since it has the exact same structure
    #create_table "canvas_oauth_authorizations", :force => true do |t|
      #t.integer  "canvas_user_id", :limit => 8
      #t.string   "token"
      #t.datetime "last_used_at"
      #t.datetime "created_at",                  :null => false
      #t.datetime "updated_at",                  :null => false
    #end
  end
end
