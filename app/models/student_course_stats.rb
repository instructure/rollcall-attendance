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

class StudentCourseStats
  attr_reader :student_id, :course_id, :section_id, :tool_consumer_instance_guid

  def initialize(student_id, course_id, section_id, tool_consumer_instance_guid)
    @student_id = student_id
    @course_id = course_id
    @section_id = section_id
    @tool_consumer_instance_guid = tool_consumer_instance_guid
  end

  def stats
    {
      presences: presences,
      tardies: tardies,
      absences: absences,
      attendance_grade: grade
    }
  end

  def presences
    @presences ||= attendance_count('present')
  end

  def tardies
    @tardies ||= attendance_count('late')
  end

  def absences
    @absences ||= attendance_count('absent')
  end

  def attendances
    @attendances ||= attendance_count
  end

  def attendance_count(attendance=nil)
    options = {
      student_id: student_id,
      section_id: section_id,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    }
    options[:attendance] = attendance if attendance.present?
    Status.where(options).count
  end

  def grade
    "#{'%.0f' % (score * 100)}%" if score
  end

  def score
    @score ||= if attendances > 0
      (presences + tardy_weight * tardies) / attendances
    end
  end

  private

  def tardy_weight
    @tardy_weight ||= CourseTardyWeight.for(course_id, tool_consumer_instance_guid)
  end
end
