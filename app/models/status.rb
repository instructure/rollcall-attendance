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

class Status < ApplicationRecord
  validates :class_date, :section_id, :student_id, :attendance, :course_id, :account_id, :teacher_id, :tool_consumer_instance_guid, presence: true

  attr_accessor :student

  def as_json(opts={})

    # Return user IDs as strings because Javascript can't handle numbers beyond
    # a certain size (which we may hit with cross-shard users)
    attributes = {
      id: id,
      attendance: attendance,
      section_id: section_id,
      course_id: course_id,
      stats: student_stats,
      student_id: student_id.to_s,
      class_date: class_date,
      teacher_id: teacher_id.to_s
    }

    attributes[:student] = student if student

    attributes = attributes.merge(seating_info)

    return attributes
  end

  def seating_info
    seating_chart = SeatingChart.latest(class_date, section_id, tool_consumer_instance_guid)
    assignment = seating_chart.assignment(student_id) if seating_chart

    {
      seated: assignment.present?,
      row: (assignment['row'] if assignment),
      col: (assignment['col'] if assignment)
    }
  end

  def student_stats
    StudentCourseStats.new(student_id, course_id, section_id, tool_consumer_instance_guid).stats
  end

  class <<self
    def initialize_list(section, class_date, teacher_id, tool_consumer_instance_guid)
      list = existing_for_section_and_date(section, class_date, tool_consumer_instance_guid)

      lookup_table = key_list_by_student_id(list)

      section.students.each do |student|
        status = lookup_table[student.id] || new(
          student_id: student.id,
          section_id: section.id,
          course_id: section.course_id,
          class_date: class_date,
          teacher_id: teacher_id,
          tool_consumer_instance_guid: tool_consumer_instance_guid,
          fixed: true
        )
        status.student = student
        list << status if status.new_record?
      end

      list = list.to_a
      list.reject! { |status| status.student.nil? }
      list.sort_by! { |status| status.student.sortable_name }
    end

    def existing_for_section_and_date(section, class_date, tool_consumer_instance_guid)
      where({
        section_id: section.id,
        class_date: class_date,
        tool_consumer_instance_guid: tool_consumer_instance_guid
      }).to_a
    end

    def key_list_by_student_id(list)
      list.inject({}) do |hash, status|
        hash[status.student_id] = status
        hash
      end
    end
  end
end
