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

require 'health_check'

class HomeController < ApplicationController
  skip_before_filter :request_canvas_authentication, :only => [:health_check]
  skip_before_filter :require_lti_launch, :only => [:health_check]

  def index
    if student_launch?
      redirect_to student_path(session[:user_id], course_id: current_course_id)
    elsif course_launch?
      redirect_to course_path(course_id: current_course_id)
    elsif account_launch?
      redirect_to account_path(current_account_id)
    else
      prompt_for_launch
    end
  end

  # NOTE: this action is publically available and should not do anything that
  # would require authentication
  def health_check
    healthy = HealthCheck.new.healthy?
    message = healthy ? 'ok' : 'down'
    status = healthy ? 200 : 500
    respond_to do |format|
      format.html { render text: message, status: status }
      format.json { render json: { message: message }, status: status }
    end
  end
end
