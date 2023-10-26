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

    Redis::Lock.new(lock_key, :expiration => 120, :timeout => 2).lock do
      # expiration and timeout are in seconds
      assignment = fetch || create
    end

    cache_assignment(assignment.to_json) if assignment

    assignment
  end

  def fetch(try_update: true)
    assignments = canvas.get_assignments(course_id)
    assignment = assignments&.find { |a| a['name'] == name }
    update_cached_assignment_if_needed(assignment) if assignment && try_update
    assignment
  end

  def fetch_from_cache
    cached_assignment = redis.get(cache_key)
    cached_assignment.blank? ? nil : JSON.parse(cached_assignment)
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

  def update_cached_assignment_if_needed(fresh_assignment)
    return nil unless fresh_assignment

    fresh_assignment_omit_from_final_grade = !!fresh_assignment['omit_from_final_grade']
    return fresh_assignment if fresh_assignment_omit_from_final_grade == course_config_omit_from_final_grade
    config = CourseConfig.find_or_initialize_by(course_id: course_id, tool_consumer_instance_guid: tool_consumer_instance_guid)
    config.update!(omit_from_final_grade: fresh_assignment_omit_from_final_grade)
    course_config_omit_from_final_grade = fresh_assignment_omit_from_final_grade
    cache_assignment(fresh_assignment.to_json)
    fresh_assignment
  end

  def course_config_omit_from_final_grade
    # Doing the nil check since ||= if omit_from_final_grade was false we'd do a lookup anyway
    if @omit_from_final_grade.nil?
      @omit_from_final_grade = !!(CourseConfig.select(:omit_from_final_grade).
        find_by(course_id: course_id, tool_consumer_instance_guid: tool_consumer_instance_guid)&.omit_from_final_grade)
    end
    @omit_from_final_grade
  end

  def course_config_omit_from_final_grade=(omit_from_final_grade)
    @omit_from_final_grade = omit_from_final_grade
  end

  def name
    "Roll Call Attendance"
  end

  def submit_grade(assignment_id, student_id)
    if assignment_id.present?
      grade = get_student_grade(student_id)
      begin
        canvas.grade_assignment(
          course_id,
          assignment_id,
          student_id,
          submission: { posted_grade: grade, submission_type: 'basic_lti_launch', url: @tool_launch_url }
        )
      rescue CanvasOauth::CanvasApi::Unauthorized
        # user is not authorized to update grades
      rescue => e
        params = {
           student_id: student_id,
           course_id: course_id,
           active_section_ids: active_section_ids,
           tool_consumer_instance_guid: tool_consumer_instance_guid
        }
        msg = "Exception when submitting grade: #{e.to_s} \nwith params:#{params.to_s}"
        Rails.logger.error msg
        raise
      end
    end
  end

  def get_assignment_grades(student_ids)
    graded_data = []
    student_ids.each do |student_id|
      graded_data << ["grade_data[#{student_id}][posted_grade]", get_student_grade(student_id)]
    end
    graded_data
  end

  def get_student_grade(student_id)
    StudentCourseStats.new(
      student_id,
      course_id,
      active_section_ids,
      tool_consumer_instance_guid
    ).grade
  end

  def submit_grades(assignment_id, student_ids)
    grades_form = URI.encode_www_form(get_assignment_grades(student_ids))
    url = "/api/v1/courses/#{course_id}/assignments/#{assignment_id}/submissions/update_grades"
    canvas.authenticated_post(url, { body: grades_form })
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
    "#{base_key}:assignment_cache_ex"
  end

  def cache_assignment(assign_json)
    expiration = 15.minutes.seconds.to_i
    redis.setex(cache_key, expiration, assign_json)
  end

  def active_section_ids
    @active_sections_ids ||= begin
      sections = cached_sections(course_id)
      sections.map { |s| s["id"] }
    end
  end
end
