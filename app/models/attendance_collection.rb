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

class AttendanceCollection
  def initialize(statuses: [], awards: [])
    @entries = Hash.new do |hash, key|
      hash[key] = Entry.new(
        course_id: key[:course_id],
        class_date: key[:class_date],
        student_id: key[:student_id],
        teacher_id: key[:teacher_id]
      )
    end

    statuses.each { |status| add_status(status) }
    awards.each { |award| add_award(award) }
  end

  def add_status(status)
    @entries[key_for(status)].add_status(status)
  end

  def add_award(award)
    @entries[key_for(award)].add_award(award)
  end

  def each(&block)
    @entries.each_key do |key|
      @entries[key].each_line(&block)
    end
  end

  def key_for(status_or_award)
    {
      course_id: status_or_award.course_id,
      class_date: status_or_award.class_date,
      student_id: status_or_award.student_id,
      teacher_id: status_or_award.teacher_id
    }
  end
  private :key_for

  # An "entry" groups attendance data by course, date, student and teacher.
  # Each entry may contain attendance statuses (for individual sections) or
  # badges awarded that day (which do not distinguish between sections).
  #
  # In the event that a student has attendance data for multiple sections,
  # we display all the awarded badges for each section. If a student has been
  # awarded badges on a given day but has not been awarded a status, we create
  # a placeholder ("unmarked") status so we have a place to show the awards.
  #
  # (Note that the above only applies to account-wide badges;
  # course-level badges are not shown at all.)
  class Entry
    attr_accessor :course_id, :student_id, :teacher_id, :class_date

    def initialize(course_id:, class_date:, student_id:, teacher_id:)
      self.course_id = course_id
      self.student_id = student_id
      self.teacher_id = teacher_id
      self.class_date = class_date

      @statuses = []
      @badge_ids = Set.new
    end

    def add_status(status)
      @statuses << status
    end

    def add_award(award)
      @badge_ids.add(award.badge_id)
    end

    def each_line
      # If we have badges but no statuses for this entry, create a placeholder
      # status so we have a place to show the badges. (If we have neither
      # statuses nor badges, this Entry object should not exist in the first
      # place.)
      working_statuses = @statuses.presence || [Status.new(**base_fields)]

      working_statuses.each do |status|
        fields_for_status = base_fields.merge({
          badge_ids: @badge_ids,
          section_id: status.section_id,
          status_description: status.attendance || "unmarked"
        })

        yield OpenStruct.new(**fields_for_status)
      end
    end

    private
    def base_fields
      {course_id: course_id, student_id: student_id, teacher_id: teacher_id, class_date: class_date}
    end
  end
end
