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

class SectionsController < ApplicationController
  before_action :can_grade

  def course
    prepare_course

    section_id = enrollments_section_ids(
      params[:course_id],
      tool_consumer_instance_guid
    ).first

    if !section_id
      section_id = load_and_authorize_sections(
        params[:course_id],
        tool_consumer_instance_guid
      ).first.id
    end

    if section_id
      redirect_to section_path(section_id)
    else
      render_error
    end
  end

  def show
    @section = load_and_authorize_full_section(
      params[:section_id],
      tool_consumer_instance_guid
    )

    return render_error if @section.blank?

    @sections = load_and_authorize_sections(
      @section.course_id,
      tool_consumer_instance_guid
    )

    if section_limited?(@section.course_id, tool_consumer_instance_guid)
      authorized_section_ids = enrollments_section_ids(
        @section.course_id,
        tool_consumer_instance_guid
      )
      @sections.select! { |sec| authorized_section_ids.include?(sec.id) }

      @section = @sections.first unless authorized_section_ids.include?(@section.id) else nil
    end

    return render_error if @section.blank? || @sections.blank?

    begin
      @course_config = CourseConfig.where(
        course_id: @section.course_id,
        tool_consumer_instance_guid: tool_consumer_instance_guid
      ).first_or_initialize
    rescue => e
      Rails.logger.error "Exception fetching section details: #{e.to_s}"
      return render_error
    end
  end

  private
  def render_error
    render plain: "There was an error loading your section. Please try re-launching the tool."
  end

  def prepare_course
    refresh_course_with_sections!(params[:course_id], tool_consumer_instance_guid)
    refresh_user_enrollments!(params[:course_id], tool_consumer_instance_guid)
  end

  def enrollments_section_ids(course_id, tool_consumer_instance_guid)
    enrollments = load_and_authorize_enrollments(
      user_id, course_id,
      tool_consumer_instance_guid
    ) || []
    enrollments.map { |enrollment| enrollment['course_section_id'] }
  end

  def section_limited?(course_id, tool_consumer_instance_guid)
    enrollments = load_and_authorize_enrollments(
      user_id,
      course_id,
      tool_consumer_instance_guid
    ) || []

    enrollments.present? &&
      enrollments.all?{ |e| e['limit_privileges_to_course_section'] }
  end
end
