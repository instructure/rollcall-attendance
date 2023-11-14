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

module CanvasCache
  def redis_key(entity, *ids)
    "#{tool_consumer_instance_guid}:#{entity}:#{ids.join(':')}"
  end

  def cached_response(key, request)
    if redis && json = redis.get(key)
      JSON.parse(json)
    else
      request.call
    end
  end

  def cached_user_enrollments(user_id)
    cached_response redis_key(:user_enrollment, user_id), lambda { canvas.get_user_enrollments(user_id) }
  end

  def cached_section(section_id)
    cached_response redis_key(:section, section_id), lambda { canvas.get_section(section_id) }
  end

  def cached_sections(course_id)
    load_and_authorize_sections(course_id, tool_consumer_instance_guid)
  end

  def cached_course(course_id)
    cached_response redis_key(:course, course_id), lambda { canvas.get_course(course_id) }
  end

  def cached_account(account_id)
    cached_response redis_key(:account, account_id), lambda { canvas.get_account(account_id) }
  end

  def cached_submission(course_id, user_id)
    cached_response redis_key(:submission, course_id, user_id), submission_request(course_id, user_id)
  end

  def submission_request(course_id, user_id)
    lambda do
      assignment = AttendanceAssignment.new(canvas, course_id, launch_url, tool_consumer_instance_guid)
      assignment_id = assignment.fetch(try_update: false).try(:[], 'id')
      if assignment_id
        response = canvas.get_submission(course_id, assignment_id, user_id)
        cache_response redis_key(:submission, course_id, user_id), response
        response
      end
    end
  end

  def refresh_course_with_sections!(course_id, tool_consumer_instance_guid)
    return unless redis

    key = redis_cache_key(tool_consumer_instance_guid, :sections_no_students, course_id, user_id)
    redis.del key

    load_and_authorize_sections(course_id, tool_consumer_instance_guid)
  end

  def refresh_user_enrollments!(course_id, tool_consumer_instance_guid)
    return unless redis

    key = redis_cache_key(tool_consumer_instance_guid, :user_enrollment, course_id, user_id)
    redis.del key

    load_and_authorize_enrollments(user_id, course_id, tool_consumer_instance_guid)
  end

  def refresh_course!(course_id)
    return unless redis
    cache_response redis_key(:course, course_id), canvas.get_course(course_id)
    cached_sections(course_id).each do |section|
      key = redis_key(:section, section['id'])
      # we may not have permission to load every section in the course, so
      # just delete them here, and they'll get refreshed lazily as needed
      redis.del key
    end
  end

  def cache_response(key, response)
    if response
      json = response.to_json
      redis.setex key, 12.hours.to_i, json
    end

    return json
  end

  def redis
    $REDIS
  end
end
