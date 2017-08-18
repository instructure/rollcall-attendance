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

require 'csv'

class AttendanceReport

  def initialize(canvas, params)
    @params = params
    @canvas = canvas
    @account = find_account
    @filters = @params[:filters] || {}
    begin
      SyncAccountRelationships.perform(@params)
    rescue CanvasOauth::CanvasApi::Unauthorized => e
      Rails.logger.error e
    end
  end

  def find_account
    account_id = @params[:account_id] ||
      @canvas.course_account_id(@params[:course_id])

    @params[:account_id] = account_id
    CachedAccount.where(
      account_id: account_id,
      tool_consumer_instance_guid: @params[:tool_consumer_instance_guid]
    ).first_or_create
  end

  def course_filter
    if @course_filter.nil?
      sis_course_id = @filters[:sis_course_id]

      course_id = if sis_course_id.present?
                    course_id = @canvas.hex_sis_id("sis_course_id", sis_course_id)
                  else
                    @params[:course_id]
                  end

      if course_id.present?
        course = @canvas.get_course(course_id)
        raise AttendanceReport::SisFilterNotFound, "Could not find course with SIS ID #{sis_course_id}" if course.not_found?
        @course_filter = Course.new(id: course['id'].to_i, sis_id: course['sis_course_id'], course_code: course['course_code'], name: course['name'])
      end
    end
    return @course_filter
  end

  def student_filter
    sis_student_id = @filters[:sis_student_id]
    if @student_filter.nil? && !sis_student_id.blank?
      student_id = @canvas.hex_sis_id("sis_user_id", sis_student_id)
      student = @canvas.get_user_profile(student_id)
      raise AttendanceReport::SisFilterNotFound, "Could not find student with SIS ID #{sis_student_id}" if student.not_found?
      @student_filter = Student.new(id: student['id'].to_i, name: student['name'], sis_id: student['sis_user_id'])
    end
    return @student_filter
  end

  def course_ids
    if @course_ids.nil?
      @course_ids = []
      [@account.statuses, @account.descendant_statuses].each do |scope|
        scope = scope.where(course_id: course_filter.id) if course_filter
        @course_ids |= scope.distinct.pluck('course_id')
      end
    end
    return @course_ids
  end

  def relevant_statuses
    statuses = []
    [@account.statuses, @account.descendant_statuses].each do |scope|
      scope = scope.where(course_id: course_ids)
      scope = scope.where(["class_date >= ?", Chronic.parse(@filters[:start_date]).to_date]) if @filters[:start_date].present?
      scope = scope.where(["class_date <= ?", Chronic.parse(@filters[:end_date]).to_date]) if @filters[:end_date].present?
      scope = scope.where(student_id: student_filter.id) if student_filter
      statuses |= scope
    end
    return statuses
  end

  def relevant_awards
    awards = Award.where(course_id: course_ids, tool_consumer_instance_guid: @params[:tool_consumer_instance_guid])
    awards = awards.where(["class_date >= ?", Chronic.parse(@filters[:start_date]).to_date]) if @filters[:start_date].present?
    awards = awards.where(["class_date <= ?", Chronic.parse(@filters[:end_date]).to_date]) if @filters[:end_date].present?
    awards = awards.where(student_id: student_filter.id) if student_filter
    return awards
  end

  def get_courses
    hash = {}

    if course_filter
      hash[course_filter.id] = course_filter
    else
      @canvas.get_report(@account.account_id, :provisioning_csv, 'parameters[courses]' => true).each do |course|
        course = Course.new(
            id: course['canvas_course_id'].to_i,
            sis_id: course['course_id'],
            course_code: course['short_name'],
            name: course['long_name'])

        hash[course.id] = course
      end
    end

    hash
  end

  def get_users
    hash = {}

    if course_filter
      @canvas.get_all_course_users(course_filter.id).each do |user|
        student = Student.new(id: user['id'],
                              name: user['name'])

        hash[student.id] = student
      end
    else
      report = @canvas.get_report(@account.account_id, :provisioning_csv, 'parameters[users]' => true)
      report.each do |student|
        student = Student.new(
            id: student['canvas_user_id'].to_i,
            name: student['first_name'] + ' ' + student['last_name'],
            sis_id: student['user_id'])

        hash[student.id] = student
      end
    end

    hash
  end

  def get_teacher_enrollments
    hash = {}

    if course_filter
      @canvas.get_course_teachers_and_tas(course_filter.id).each do |user|
        hash[course_filter.id] = user['id']
      end
    else
      report = @canvas.get_report(@account.account_id, :provisioning_csv, 'parameters[enrollments]' => true)
      report.each do |teacher|
        valid_roles = %w(teacher ta)

        if teacher['status'] == 'active' && teacher['role'].in?(valid_roles)
          hash[teacher['canvas_course_id'].to_i] = teacher['canvas_user_id'].to_i
        end
      end
    end

    hash
  end

  def header
    header = ["Course ID", "SIS Course ID", "Course Code", "Course Name"]
    if course_filter
      header.concat ["Teacher ID", "Teacher Name"]
      header.concat ["Student ID", "Student Name"]
    else
      header.concat ["Teacher ID", "SIS Teacher ID", "Teacher Name"]
      header.concat ["Student ID", "SIS Student ID", "Student Name"]
    end
    header.concat ["Class Date", "Attendance", "Timestamp"]

    header << "Badges" if @account.badges.length > 0
    header.concat @account.badges.map(&:name)
  end

  def to_csv
    courses = get_courses
    users = get_users
    teachers = get_teacher_enrollments

    attendance_collection = AttendanceCollection.new
    relevant_statuses.each { |status| attendance_collection.add_status status }
    relevant_awards.each { |award| attendance_collection.add_award award }

    CSV.generate do |csv|
      csv << header
      attendance_collection.each do |attendance|
        teacher_id = attendance.teacher_id || teachers[attendance.course_id]
        next unless users[attendance.student_id]
        csv << course_columns(courses[attendance.course_id]) +
            user_columns(users[teacher_id]) +
            user_columns(users[attendance.student_id]) +
            attendance_columns(attendance)
      end
    end
  end

  def course_columns(course)
    return ['', '', '', ''] if course.nil?
    return [course.id, course.sis_id, course.course_code, course.name]
  end

  def user_columns(user)
    if user.nil?
      course_filter ? ['', ''] : ['', '', '']
    elsif course_filter
      [user.id, user.name]
    else
      [user.id, user.sis_id, user.name]
    end
  end

  def attendance_columns(attendance)
    columns = [attendance.class_date, attendance.status_description, attendance.last_updated_at]
    columns << ''
    @account.badges.each do |badge|
      if attendance.awards[badge.id]
        columns << badge.name
      else
        columns << ''
      end
    end
    columns
  end


  class SisFilterNotFound < StandardError;
  end
end
