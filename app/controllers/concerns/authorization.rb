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
module Authorization
  include RedisCache
  include HttpCanvasHelper

  def load_and_authorize_enrollments(user_id, course_id, tool_consumer_instance_guid)
    object = get_object(
      tool_consumer_instance_guid,
      :user_enrollment,
      course_id,
      lambda { get_course_enrollments_for_user(user_id, course_id) }
    )
  end

  def aggregate_course_enrollments_for_user(user_id, course_id)
    page = 1
    enrollments = []
    bookmark = 'first'

    loop do
      enrollments_fetched = []
      query_options = {
        type: %w[TeacherEnrollment TaEnrollment],
        state: %w[active completed],
        user_id: user_id.to_s,
        per_page: 50,
        page: bookmark
      }

      enrollments_fetched, bookmarks = HttpCanvasAuthorizedRequest
        .new(
          canvas,
          "/api/v1/courses/#{course_id}/enrollments",
          query_options
        )
        .send_request_with_link_headers

      bookmark = bookmarks['next']

      page = page + 1
      enrollments = enrollments + enrollments_fetched

      break if enrollments_fetched.count != 50
    end

    enrollments
    rescue => e
      Rails.logger.error "Exception fetching enrollments list: #{e.to_s}"
  end

  def get_course_enrollments_for_user(user_id, course_id)
    enrollments_list = aggregate_course_enrollments_for_user(user_id, course_id)

    enrollments_list
  end

  def load_and_authorize_section(section_id, tool_consumer_instance_guid)
    object = get_object(
      tool_consumer_instance_guid,
      :section,
      section_id,
      lambda { canvas.get_section(section_id) }
    )
    return Section.new(object) unless object.empty?
  end

  def load_and_authorize_course(course_id, tool_consumer_instance_guid)
    object = get_object(
      tool_consumer_instance_guid,
      :course,
      course_id,
      lambda { canvas.get_course(course_id) }
    )
    return Course.new(object) unless object.empty?
  end

  def load_and_authorize_account(account_id, tool_consumer_instance_guid)
    object = get_object(
      tool_consumer_instance_guid,
      :account,
      account_id,
      lambda { canvas.get_account(account_id) }
    )
    unless object.empty?
      CachedAccount.where(
        account_id: account_id,
        tool_consumer_instance_guid: tool_consumer_instance_guid
      ).first_or_create
    end

  end

  def load_and_agregate_sections(course_id, includes=[])
    page = 1
    sections = []

    loop do
      sections_fetched = []
      query_options = { query: { include: includes, per_page: 50, page: page } }

      sections_fetched = canvas.authenticated_get("/api/v1/courses/#{course_id}/sections", query_options)

      sections_fetched.each do |section|
        sections << section
      end

      page = page + 1

      break if sections_fetched.count != 50
    end

    sections
  end

  def load_and_authorize_sections(course_id, tool_consumer_instance_guid, includes = [])
    if load_and_authorize_course(course_id, tool_consumer_instance_guid)

      object = get_object(
        tool_consumer_instance_guid,
        includes.empty? ? :sections_no_students : :sections_w_students,
        course_id,
        lambda { load_and_agregate_sections(course_id, includes) }
      )

      Section.list_from_params(object)  unless object.empty?
    end

  end

  # This returns the section with student enrollments
  def load_and_authorize_full_section(section_id, tool_consumer_instance_guid)
    query_options = { query: { include: ['students', 'enrollments', 'avatar_url'] } }
    object = get_object(
      tool_consumer_instance_guid,
      :section_student_enrollments,
      section_id,
      lambda { canvas.authenticated_get("/api/v1/sections/#{section_id}", query_options) }
    )
    return Section.new(object) unless object.empty?
  end

  def load_and_authorize_student(course_id, user_id)
    course_id && user_id && authorize_resource(:student, user_id, submission_request(course_id, user_id))
  end

  def get_object(tool_consumer_instance_guid, resource_type, resource_id, canvas_request)
    key = redis_cache_key(
      tool_consumer_instance_guid,
      resource_type,
      resource_id,
      user_id
    )

    response = redis_cache_response key, canvas_request
    response
  end

  def authorize_resource(resource_type, resource_id, canvas_request)
    if authorized?(resource_type, resource_id)
      true
    elsif canvas_authorized? { canvas_request.call }
      authorize(resource_type, resource_id)
    end

  end

  def cached_authorization(type)
    session[:authorization] ||= {}
    session[:authorization][type] ||= []
  end

  def authorize(type, id)
    cached_authorization(type) << id.to_i
  end

  def authorized?(type, id)
    cached_authorization(type).include?(id.to_i)
  end

  def canvas_authorized?(&block)
    response = yield
    # The Canvas API returns an actual response except when returning
    # paginated results. When requesting paginated resources it returns
    # an Array.
    if response
      if response.kind_of?(Array)
        response.size > 0
      else
        response.success?
      end
    end
  end
end
