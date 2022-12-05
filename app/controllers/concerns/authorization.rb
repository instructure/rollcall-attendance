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
  def load_and_authorize_enrollments(user_id, course_id)
    if user_id &&
      authorize_resource(
        :user_enrollment,
        user_id,
        lambda { get_course_enrollments_for_user(user_id, course_id) }
      )
      get_course_enrollments_for_user(user_id, course_id)
    end
  end

  def get_course_enrollments_for_user(user_id, course_id)
    query_options = {
      query: {
        type: ['TeacherEnrollment', 'TaEnrollment'],
        state: ['active', 'completed'],
        user_id: user_id.to_s,
        per_page: 100
      }
    }
    canvas.authenticated_get "/api/v1/courses/#{course_id}/enrollments", query_options
  end

  def load_and_authorize_section(section_id)
    if section_id && (authorize_resource :section, section_id, lambda { canvas.get_section(section_id) })
      Section.new(cached_section(section_id))
    end
  end

  def load_and_authorize_course(course_id)
    if course_id && authorize_resource( :course, course_id, lambda { canvas.get_course(course_id) })
      Course.new(cached_course(course_id))
    end
  end

  def load_and_authorize_account(account_id, tool_consumer_instance_guid)
    if account_id && (authorize_resource :account, account_id, lambda { canvas.get_account(account_id) })
      CachedAccount.where(
        account_id: account_id,
        tool_consumer_instance_guid: tool_consumer_instance_guid
      ).first_or_create
    end
  end

  def load_and_authorize_sections(course_id)
    if load_and_authorize_course(course_id)
      Section.list_from_params(cached_sections(course_id))
    end
  end

  # This method exists because when you just fetch an individual section it doesn't include the list of students
  # So here we are fetching the full list of sections on a course which does include the students and then selecting the one we want
  def load_and_authorize_full_section(section_id)
    section = load_and_authorize_section(section_id)

    if section && course_id = section.course_id
      if sections = load_and_authorize_sections(course_id)
        sections.find { |s| s.id.to_i == section_id.to_i }
      end
    end
  end

  def load_and_authorize_student(course_id, user_id)
    course_id && user_id && authorize_resource(:student, user_id, submission_request(course_id, user_id))
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
