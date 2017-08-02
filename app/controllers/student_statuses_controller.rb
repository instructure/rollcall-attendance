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

class StudentStatusesController < ApplicationController
  before_action :authorize_student

  # renders a paginated list of statuses for a given student in a given course
  #
  # endpoint: /courses/:course_id/students/:student_id/student_statuses
  #
  # params:
  #   - course_id: Canvas course ID
  #   - student_id: Canvas user ID of student
  #   - attendance_scope (optional): Array of attendance statuses to filter by (one or more of ['absent', 'present', 'late'])
  def index
    @statuses = Status.where(student_id: params[:student_id], course_id: params[:course_id], tool_consumer_instance_guid: session[:tool_consumer_instance_guid])
      .order(class_date: :desc).paginate(pagination_params)

    @statuses = @statuses.where(attendance: params[:attendance_scope]) if params[:attendance_scope].present?

    render json: collection_json(@statuses)
  end

  # renders the count of statuses in each attendance value, as well as submission information from Canvas
  #
  # endpoint: /courses/:course_id/students/:student_id/student_statuses/summary
  #
  # params:
  #   - course_id: Canvas course ID
  #   - student_id: Canvas user ID of student
  def summary
    submission = cached_submission(params[:course_id], params[:student_id]) || {}
    submission.symbolize_keys!

    base_query = Status.where(student_id: params[:student_id], course_id: params[:course_id], tool_consumer_instance_guid: session[:tool_consumer_instance_guid])
    present_statuses = base_query.where(attendance: 'present').count
    late_statuses = base_query.where(attendance: 'late').count
    absent_statuses = base_query.where(attendance: 'absent').count
    tardy_weight = CourseTardyWeight.for(params[:course_id], session[:tool_consumer_instance_guid])

    render json: {
      present_statuses: present_statuses,
      late_statuses: late_statuses,
      absent_statuses: absent_statuses,
      grade: submission[:grade],
      tardy_weight: tardy_weight
    }
  end

  private
  def authorize_student
    load_and_authorize_student(params[:course_id], params[:student_id])
  end
end
