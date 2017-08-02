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

class ApplicationController < ActionController::Base
  prepend_before_filter :stub_session

  def stub_session
    session[:canvas_url] = "http://test.canvas"
    session[:user_id] = 2
    session[:tool_consumer_instance_guid] = 'abc123'
    session[:user_roles] = 'urn:lti:role:ims/lis/Instructor'
  end

  protected
  def current_course_id
    1
  end

  def canvas_token
    1
  end
end
