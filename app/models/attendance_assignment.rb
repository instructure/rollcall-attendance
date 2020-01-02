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
  include CanvasCache

  attr_accessor :canvas, :course_id, :tool_launch_url, :tool_consumer_instance_guid

  def initialize(canvas, course_id, tool_launch_url, tool_consumer_instance_guid)
    @canvas = canvas
    @course_id = course_id
    @tool_launch_url = tool_launch_url
    @tool_consumer_instance_guid = tool_consumer_instance_guid
  end

  def fetch_or_create
    assignment = fetch_from_cache

    return assignment if assignment

    Redis::Lock.new(lock_key, :expiration => 120, :timeout => 0.5).lock do
      # expiration and timeout are in seconds
      assignment = fetch || create
    end

    redis.set(cache_key, assignment.to_json) if assignment

    assignment
  end

  def fetch
    assignments = canvas.get_assignments(course_id)
    assignment = assignments&.find { |a| a['name'] == name }
    update_if_needed(assignment: assignment) if assignment
    assignment
  end

  def fetch_from_cache
    canvas_assignment = redis.get(cache_key)
    canvas_assignment = if canvas_assignment.blank?
      nil
    else
      update_if_needed(assignment: JSON.parse(canvas_assignment), update_cache: true)
    end
    canvas_assignment
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
      },
      omit_from_final_grade: course_config_omit_from_final_grade
    }

    canvas.create_assignment(course_id, options)
  end

  def update_if_needed(assignment:, update_cache: false)
    return nil unless assignment

    canvas_assignment_omit_from_final_grade = !!assignment['omit_from_final_grade']
    return assignment if canvas_assignment_omit_from_final_grade == course_config_omit_from_final_grade

    options = { omit_from_final_grade: course_config_omit_from_final_grade }
    updated_assignment = canvas.update_assignment(course_id, assignment['id'], options)
    redis.set(cache_key, updated_assignment.to_json) if update_cache
    assignment
  end

  def course_config_omit_from_final_grade
    # Doing the nil check since ||= if omit_from_final_grade was false we'd do a lookup anyway
    if @omit_from_final_grade.nil?
      @omit_from_final_grade = !!(CourseConfig.select(:omit_from_final_grade).
        find_by(course_id: course_id, tool_consumer_instance_guid: tool_consumer_instance_guid)&.omit_from_final_grade)
    end
    @omit_from_final_grade
  end

  def name
    "Roll Call Attendance"
  end

  def submit_grade(assignment_id, student_id)
    if assignment_id.present?
      grade = StudentCourseStats.new(
        student_id,
        course_id,
        active_section_ids,
        tool_consumer_instance_guid
      ).grade
      begin
        canvas.grade_assignment(
          course_id,
          assignment_id,
          student_id,
          submission: { posted_grade: grade, submission_type: 'basic_lti_launch', url: @tool_launch_url }
        )
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

  def active_section_ids
    @active_sections_ids ||= begin
      sections = cached_sections(course_id)
      sections.map { |s| s["id"] }
    end
  end
end
