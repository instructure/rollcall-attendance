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

class CourseConfigsController < ApplicationController
  before_action :can_grade

  respond_to :json

  def create
    config_params = course_config_params
    config = CourseConfig.new(config_params)
    config.tool_consumer_instance_guid = tool_consumer_instance_guid
    saved = config.save if authorized_to_update_config?(config)
    resubmit_all_grades!(config) if saved && config.needs_regrade
    update_canvas_assignment(config_params, config.course_id) if saved
    respond_with config
  end

  def update
    if config = CourseConfig.find_by(id: params[:id])
      config_params = course_config_params
      config.attributes = config_params
      saved = config.save if authorized_to_update_config?(config)
      resubmit_all_grades!(config) if saved && config.needs_regrade
      update_canvas_assignment(config_params, config.course_id) if saved
      respond_with config
    else
      head :not_found
    end
  end

  protected

  def update_canvas_assignment(config_params, course_id)
    return unless config_params.key? :omit_from_final_grade
    omit_from_final_grade = !!ActiveModel::Type::Boolean.new.cast(config_params[:omit_from_final_grade])

    updater_params = {
      canvas_url: canvas_url,
      course_id: course_id,
      options: { omit_from_final_grade: omit_from_final_grade },
      tool_consumer_instance_guid: tool_consumer_instance_guid,
      tool_launch_url: launch_url,
      user_id: user_id
    }

    assignment_updater = CanvasAssignmentUpdater.new(updater_params)
    assignment_updater.enqueue!
  end

  def authorized_to_update_config?(config)
    config.course_id && load_and_authorize_course(
      config.course_id,
      config.tool_consumer_instance_guid
    )
  end

  def course_sections(config)
    load_and_authorize_sections(config.course_id, config.tool_consumer_instance_guid, ['students'])
  end

  def course_config_params
    params.require(:course_config).permit(:course_id, :tardy_weight, :view_preference, :omit_from_final_grade)
  rescue ActionController::ParameterMissing
    {}
  end

  def resubmit_all_grades!(config)
    sections = course_sections(config)
    student_ids = sections.map { |s| s.students.map(&:id) }.flatten.uniq
    grade_params = {
      canvas_url: canvas_url,
      user_id: user_id,
      course_id: config.course_id,
      student_ids: student_ids,
      tool_consumer_instance_guid: tool_consumer_instance_guid,
      identifier: SecureRandom.hex(32),
      tool_launch_url: launch_url
    }
    course_grade_updater = AllGradeUpdater.new(grade_params)
    course_grade_updater.enqueue!
  end
end
