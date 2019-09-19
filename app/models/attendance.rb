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

class Attendance
  attr_accessor :course_id, :section_id, :student_id, :class_date, :status, :awards, :teacher_id

  def initialize(params)
    @awards = {}
    if params.has_key? :status
      set_keys params[:status]
      @status = params[:status]
      @section_id = params[:status].section_id
    elsif params.has_key? :award
      set_keys params[:award]
      add_award(params[:award])
    else
      @course_id = params[:course_id]
      @section_id = params[:section_id]
      @student_id = params[:student_id]
      @teacher_id = params[:teacher_id]
      @class_date = params[:class_date]
    end
  end

  #object needs to have the following four attributes
  def set_keys(object)
    @course_id = object.course_id
    #@section_id = object.section_id
    @student_id = object.student_id
    @teacher_id = object.teacher_id
    @class_date = object.class_date
  end

  def add_award(award)
    @awards[award.badge_id] = award
  end

  def status_description
    return (status ? status.attendance : "unmarked")
  end

  def last_updated_at
    last_updated_at = status.updated_at if status
    @awards.each_value do |award|
      last_updated_at = award.updated_at if last_updated_at.nil? || award.updated_at > last_updated_at
    end
    last_updated_at
  end

  def eql? (attendance)
    @course_id == attendance.course_id &&
        @section_id == attendance.section_id &&
        @student_id == attendance.student_id &&
        @teacher_id == attendance.teacher_id &&
        @class_date == attendance.class_date
  end

  def hash
    [@course_id, @section_id, @student_id, @teacher_id, @class_date].hash
  end
end
