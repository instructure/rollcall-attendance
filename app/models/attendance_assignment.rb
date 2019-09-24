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

class AttendanceAssignment
  attr_accessor :canvas, :course_id, :tool_launch_url

  def initialize(canvas, course_id, tool_launch_url)
    @canvas, @course_id, @tool_launch_url = canvas, course_id, tool_launch_url
  end

  def fetch_or_create
    assignment = nil

    assign_id = fetch_from_cache
    return assign_id if assign_id

    Redis::Lock.new(lock_key, :expiration => 120, :timeout => 0.5).lock do
      # expiration and timeout are in seconds
      assignment = fetch || create
    end

    redis.set(cache_key, assignment['id']) if assignment
    assignment['id'] if assignment
  end

  def fetch
    if assignments = canvas.get_assignments(course_id)
      assignments.find { |a| a['name'] == name }
    end
  end

  def fetch_from_cache
    assign_id = redis.get(cache_key)
    return nil if assign_id.blank?

    assignment = canvas.get_assignment(course_id, assign_id)
    if assignment['name'] == name
      return assign_id
    else
      redis.del(cache_key)
      return nil
    end
  end

  def create
    options = {
      name: name,
      grading_type: "percent",
      points_possible: 100,
      published: true,
      submission_types: ['external_tool'],
      external_tool_tag_attributes: {
        url: tool_launch_url,
        new_tab: false
      }
    }

    canvas.create_assignment(course_id, options)
  end

  def name
    "Roll Call Attendance"
  end

  def submit_grade(assignment_id, student_id, section_id, tool_consumer_instance_guid)
    if assignment_id.present?
      grade = StudentCourseStats.new(
        student_id,
        course_id,
        section_id,
        tool_consumer_instance_guid
      ).grade
      begin
        canvas.grade_assignment(course_id, assignment_id, student_id, submission: { posted_grade: grade, submission_type: 'basic_lti_launch', url: @tool_launch_url })
      rescue CanvasOauth::CanvasApi::Unauthorized
        # user is not authorized to update grades
      end
    end
  end

  def redis
    Redis.current
  end

  def base_key
    "attendance_assignment.#{@canvas.canvas_url}.course_#{@course_id}"
  end

  def lock_key
    base_key
  end

  def cache_key
    "#{base_key}:cache"
  end
end
