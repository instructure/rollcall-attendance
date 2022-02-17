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
require 'net/http'

class SectionsController < ApplicationController
  before_action :can_grade
  respond_to :json

  include HttpCanvasHelper

  def index
    @course_id = params[:course_id]
    @per_page = params[:per_page]
    @page = params[:page]

    @section_list = get_section_list_service

    @section_list.each do |section|
      section = Section.new(section)
    end

    respond_with @section_list
  end

  def course
    if section_id = enrollments_section_ids(params[:course_id]).first
      redirect_to section_path(section_id)
    elsif section = load_and_authorize_sections(params[:course_id]).first
      redirect_to section_path(section.id)
    else
      render_error
    end
  end

  def get_section_service(params)
    service = HttpCanvasAuthorizedRequest.new(canvas, "/api/v1/sections/#{params[:section_id]}")
    service.send_request
  end

  def get_section_list_service
    service = HttpCanvasAuthorizedRequest.new(canvas, "/api/v1/courses/#{@course_id}/sections?per_page=#{@per_page || 50}&page=#{@page || 1}")
    service.send_request
  end

  def show
    @section = get_section_service(params)

    return render_error if @section.blank?

    @course_id = @section.course_id

    @sections = get_section_list_service

    if section_limited?(@section.course_id)
      authorized_section_ids = enrollments_section_ids(@section.course_id)
      @sections.select! { |sec| authorized_section_ids.include?(sec.id) }
      @section = nil unless authorized_section_ids.include?(@section.id)
    end

    render_error if @section.blank? || @sections.blank?

    @course_config = CourseConfig.where(
      course_id: @section.course_id,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    ).first_or_initialize
  end

  private
  def render_error
    render plain: "There was an error loading your section. Please try re-launching the tool."
  end

  def prepare_course
    refresh_course!(params[:course_id])
  end

  def enrollments_section_ids(course_id)
    enrollments = load_and_authorize_enrollments(user_id, course_id) || []
    enrollments.map { |enrollment| enrollment['course_section_id'] }
  end

  def section_limited?(course_id)
    enrollments = load_and_authorize_enrollments(user_id, course_id) || []
    enrollments.present? &&
      enrollments.all?{ |e| e['limit_privileges_to_course_section'] }
  end
end
