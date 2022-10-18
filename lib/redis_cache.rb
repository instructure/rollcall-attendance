#
# Copyright (C) 2021 - present Instructure, Inc.
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

module RedisCache

  def redis
    Redis.current
  end

  def redis_cache_key(*params)
    "#{params.join(':')}"
  end

  def is_cached?(key)
    redis.exists?(key)
  end

  def cached_value(key)
    redis.get(key)
  end

  def cache_value(key, expiration = 60, value)
    redis.setex key, expiration, value
  end

  def redis_cache_response(key, request)
    response_cached_value = cached_value(key)

    JSON.parse(response_cached_value || fetch_from_api(key, request))
  end

  def fetch_from_api(key, request)
    response = request.call

    return "{}" if response.blank?


    if response.class == HTTParty::Response
      return "{}" if response.body.blank?
      response = response.body
    else
      response = response.to_json
    end

    cache_value key, 1.hours.to_i, response

    response
  end

  # def get_section_student_enrollments(section_id, tool_consumer_instance_guid)
  #   # key = redis_cache_key(tool_consumer_instance_guid, :section_students, section_id)

  #   lambda { canvas.authenticated_get("/api/v1/sections/#{section_id}", query_options) }
  #   # redis_cache_response key, request
  # end

  # def get_course_sections(course_id, tool_consumer_instance_guid)
  #   query_options = { query: { include: [] } }
  #   request = lambda { canvas.authenticated_get("/api/v1/courses/#{course_id}/sections", query_options) }
  #   # redis_cache_response key, request
  # end
end
