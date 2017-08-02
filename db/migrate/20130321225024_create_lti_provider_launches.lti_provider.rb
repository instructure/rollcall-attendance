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
# This migration comes from lti_provider (originally 20130319050003)
class CreateLtiProviderLaunches < ActiveRecord::Migration
  def change
    create_table "lti_provider_launches", :force => true do |t|
      t.string   "canvas_url"
      t.string   "nonce"
      t.text     "provider_params"

      t.timestamps
    end
  end
end
