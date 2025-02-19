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

class StatusesController < ApplicationController
  before_action :can_grade

  respond_to :json

  def index
    section = load_and_authorize_full_section(params[:section_id], tool_consumer_instance_guid)
    begin
      if section
        statuses = Status.initialize_list(
          section,
          params[:class_date],
          user_id,
          tool_consumer_instance_guid
        )
        respond_with statuses
      else
        not_acceptable
      end
    rescue => e
      Rails.logger.error "Exception: #{e.class.name} - #{e.message}. Params: #{params.inspect}"
      not_acceptable
    end
  end

  def create
    begin
      course_id = params[:status][:course_id]
      if course = load_and_authorize_course(course_id, tool_consumer_instance_guid)
        #This makes sure that the Status is unique for the student and
        #the corresponding course.
        status = Status.where(
          student_id: params[:status][:student_id],
          section_id: params[:status][:section_id],
          class_date: params[:status][:class_date],
          course_id: params[:status][:course_id],
          tool_consumer_instance_guid: tool_consumer_instance_guid
        ).first

        status ||= Status.new(status_params)
        status.assign_attributes(
          course_id: course.id,
          account_id: course.account_id
        )

        if status.save
          submit_grade!(status)
          handle_last_attended_date(status)
        end
        render_status(status)
      else
        not_acceptable
      end
    rescue ActiveRecord::RecordNotUnique
      Rails.logger.error "Exception creating attendance: Duplicate record. Params: #{params.inspect}"
    rescue => e
      Rails.logger.error "Exception creating attendance: #{e.to_s}. Params: #{params.inspect}"
    end
  end

  def update
    if status = Status.find_by(id: params[:id])
      if load_and_authorize_section(status.section_id, status.tool_consumer_instance_guid)
        previous_attendance = status.attendance
        status.attendance = status_params[:attendance]
        status.teacher_id = user_id

        if status.save
          submit_grade!(status)
          handle_last_attended_date(status, previous_attendance)
        end
        render_status(status)
      else
        not_acceptable
      end
    else
      head :not_found
    end
  end

  def destroy
    if status = Status.find_by(id: params[:id])
      if load_and_authorize_section(status.section_id, status.tool_consumer_instance_guid)
        previous_attendance = status.attendance

        if status.destroy
          submit_grade!(status)
          handle_last_attended_date(status, previous_attendance, recalculate: true)
        end

        render_status(status)
      else
        not_acceptable
      end
    else
      head :not_found
    end
  end

  protected
  def submit_grade!(status)
    grade_params = {
      canvas_url: canvas_url,
      user_id: user_id,
      student_id: status.student_id,
      section_id: status.section_id,
      course_id: status.course_id,
      tool_consumer_instance_guid: status.tool_consumer_instance_guid,
      tool_launch_url: launch_url
    }

    grade_updater = GradeUpdater.new(grade_params)
    strand_name = "tool_consumer_instance_guid:"
    strand_name << status.tool_consumer_instance_guid
    strand_name << ":course_id:#{status.course_id}"

    grade_updater.delay(n_strand: strand_name).submit_grade
  end

  def render_status(status)
    respond_to do |format|
      format.json { render json: status.as_json }
    end
  end

  private
  def status_params
    params.require(:status).permit(:class_date, :attendance, :section_id, :student_id, :course_id).merge({
      tool_consumer_instance_guid: tool_consumer_instance_guid,
      teacher_id: user_id,
      fixed: true
    })
  end

  def handle_last_attended_date(status, previous_attendance = nil, recalculate: false)
    if recalculate || (previous_attendance && ['present', 'late'].include?(previous_attendance) && !['present', 'late'].include?(status.attendance))
      update_last_attended_date(status, recalculate: true)
    elsif ['present', 'late'].include?(status.attendance)
      update_last_attended_date(status)
    end
  end

  def update_last_attended_date(status, recalculate: false)
    last_date = if recalculate
      StudentCourseStats.new(
        status.student_id, 
        status.course_id, 
        status.section_id, 
        status.tool_consumer_instance_guid
      ).last_attended_date
    else
      status.class_date
    end

    submit_last_attended_date(status.course_id, status.student_id, last_date) if last_date
  end

  def submit_last_attended_date(course_id, student_id, date)
    url = "#{canvas_url}/api/v1/courses/#{course_id}/users/#{student_id}/last_attended?date=#{date}"
    canvas.authenticated_put(url, {})
  end
end