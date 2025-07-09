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
  include RedisCache

  def initialize(canvas, params)
    @params = params
    @canvas = canvas
    @account = find_account
    @subaccounts = find_subaccounts
    @filters = @params[:filters] || {}
    begin
      account_relationship = SyncAccountRelationships.new(@params)
      account_relationship.enqueue!
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

  def find_subaccounts
    return [] unless @params[:account_id] && @params[:subaccount_ids]

    @params[:subaccount_ids].map do |subaccount_id|
      CachedAccount.where(
        account_id: subaccount_id,
        parent_account_id: @params[:account_id],
        tool_consumer_instance_guid: @params[:tool_consumer_instance_guid]
      ).first_or_create
    end


  end

  def course_filter
    if @course_filter.nil?
      sis_course_id = @filters[:sis_course_id]

      course_id = @canvas.hex_sis_id("sis_course_id", sis_course_id) if sis_course_id.present?
      course_id ||= @params[:course_id]

      if course_id.present?
        course = @canvas.get_course(course_id)
        raise AttendanceReport::SisFilterNotFound, "Could not find course with SIS ID #{sis_course_id}" if course.not_found?
        @course_filter = Course.new(id: course['id'].to_i, sis_id: course['sis_course_id'], course_code: course['course_code'], name: course['name'])
      end
    end
    @course_filter
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
    # Only account-wide badges ever get shown in reports, whether they are
    # course-level or account-level reports.
    awards = Award.joins(:badge).
      where(course_id: course_ids, tool_consumer_instance_guid: @params[:tool_consumer_instance_guid]).
      where(badges: {course_id: nil})
    awards = awards.where(["class_date >= ?", Chronic.parse(@filters[:start_date]).to_date]) if @filters[:start_date].present?
    awards = awards.where(["class_date <= ?", Chronic.parse(@filters[:end_date]).to_date]) if @filters[:end_date].present?
    awards = awards.where(student_id: student_filter.id) if student_filter
    awards
  end

  def get_courses
    hash = {}

    if course_filter
      hash[course_filter.id] = course_filter
    else
      params = {
        'parameters[courses]' => true,
        'parameters[include_deleted]' => true
      }
      ([@account] + @subaccounts).each do |account|
        @canvas.get_report(account.account_id, :provisioning_csv, params).each do |course|
          course = Course.new(
            id: course['canvas_course_id'].to_i,
            sis_id: course['course_id'],
            course_code: course['short_name'],
            name: course['long_name']
          )
          hash[course.id] = course
        end
      end
    end

    hash
  end

  def get_users
    students = []
    if course_filter
      @canvas.get_all_course_users(course_filter.id).each do |user|
        students << Student.new(id: user['id'],
                                name: user['name'])
      end
    else
      ([@account] + @subaccounts).each do |account|
        students += get_users_by_account(account)
      end
    end

    students_to_hash(students)
  end

  def students_to_hash(students)
    students.group_by(&:id).transform_values do |grouped_students|
      student = grouped_students.first
      student.sis_id = grouped_students.find { |s| s.sis_id.present? }&.sis_id if student.sis_id.blank?
      student
    end
  end

  def get_users_by_account(account)
    students = []
    report = @canvas.get_report(account.account_id, :provisioning_csv, 'parameters[users]' => true)
    report.each do |student|
      students << Student.new(
        id: student['canvas_user_id'].to_i,
        name: student['first_name'] + ' ' + student['last_name'],
        sis_id: student['user_id'])
    end

    students
  end

  def get_teacher_enrollments
    teacher_enrollments = []

    if course_filter
      @canvas.get_course_teachers_and_tas(course_filter.id).each do |user|
        teacher_enrollments << { course_id: course_filter.id, user_id: user['id'] }
      end
    else
      ([@account] + @subaccounts).each do |account|
        teacher_enrollments += get_teacher_enrollments_by_account(account)
      end
    end

    teacher_enrollments_to_hash(teacher_enrollments)
  end

  def teacher_enrollments_to_hash(teacher_enrollments)
    teacher_enrollments.map { |e| [e[:course_id], e[:user_id]] }.to_h
  end

  def get_teacher_enrollments_by_account(account)
    params = {
      'parameters[enrollments]' => true,
      'parameters[enrollment_filter]' => 'TeacherEnrollment,TaEnrollment',
      'parameters[enrollment_states]' => 'active'
    }

    teacher_enrollments = []
    report = @canvas.get_report(account.account_id, :provisioning_csv, params)
    report.each do |teacher|
      teacher_enrollments << { course_id: teacher['canvas_course_id'].to_i, user_id: teacher['canvas_user_id'].to_i }
    end

    teacher_enrollments
  end


  def header
    header = ["Course ID", "SIS Course ID", "Course Code", "Course Name", "Section Name", "Section ID", "SIS Section ID"]
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

    attendance_collection = AttendanceCollection.new(statuses: relevant_statuses, awards: relevant_awards)

    CSV.generate do |csv|
      csv << header
      attendance_collection.each do |attendance|
        teacher_id = attendance.teacher_id || teachers[attendance.course_id]
        next unless users[attendance.student_id] && section_exists?(attendance.section_id)
        csv << course_columns(courses[attendance.course_id]) +
            section_columns(attendance.section_id) +
            user_columns(users[teacher_id]) +
            user_columns(users[attendance.student_id]) +
            attendance_columns(attendance)
      end
    end
  end

  def course_columns(course)
    return Array.new(4) {''} if course.nil?
    [course.id, course.sis_id, course.course_code, course.name]
  end

  def section_exists?(section_id)
    return true if section_id.nil?
    section = get_section(section_id)
    return false if section['name'].nil?
    true
  end

  def section_columns(section_id)
    return Array.new(3) {''} if section_id.nil?
    section = get_section(section_id)
    [section['name'], section_id, section['sis_section_id']]
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
      columns << (attendance.badge_ids.include?(badge.id) ? badge.name : '')
    end
    columns
  end

  def get_section(section_id)
    key = redis_cache_key(@params[:tool_consumer_instance_guid], :section, section_id)
    request = lambda { @canvas.get_section(section_id) }
    redis_cache_response key, request
  end

  class SisFilterNotFound < StandardError;
  end
end
