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

require 'spec_helper'

describe "AttendanceCollection" do
  subject(:collection) { AttendanceCollection.new }

  let(:first_student_id) { 1 }
  let(:second_student_id) { 2 }

  let(:first_teacher_id) { 1001 }
  let(:second_teacher_id) { 1002 }

  let(:date) { 4.days.ago.to_date }

  let(:course_id) { 1 }
  let(:alternate_course_id) { 2 }

  let(:first_student_status) { make_status(section_id: 101) }
  let(:second_student_status) { make_status(student_id: second_student_id, section_id: 101) }

  let(:first_student_awards) { [make_award, make_award(badge_id: 2)] }
  let(:second_student_award) { make_award(student_id: second_student_id) }

  let(:collection_items) do
    output = []
    collection.each { |line| output << line }

    output
  end

  def make_status(**params)
    default_params = {
      course_id: course_id,
      student_id: first_student_id,
      teacher_id: first_teacher_id,
      class_date: date,
      attendance: "present",
      updated_at: Time.zone.now
    }

    status_params = default_params.merge(params)
    Status.new(**status_params)
  end

  def make_award(**params)
    default_params = {
      course_id: course_id,
      student_id: first_student_id,
      teacher_id: first_teacher_id,
      class_date: date,
      badge_id: 1,
      updated_at: Time.zone.now
    }
    award_params = default_params.merge(params)
    Award.new(**award_params)
  end

  describe "population" do
    let(:collection) do
      AttendanceCollection.new(statuses: [first_student_status], awards: first_student_awards)
    end

    it "accepts statuses added at initialization and via add_status" do
      expect(collection_items.pluck(:student_id)).to include(first_student_id)
    end

    it "accepts statuses added via add_status" do
      collection.add_status(second_student_status)
      expect(collection_items.pluck(:student_id)).to include(second_student_id)
    end

    it "accepts awards added at initialization" do
      first_student_items = collection_items.select { |item| item.student_id == first_student_id }
      expect(first_student_items.first.badge_ids).to contain_exactly(1, 2)
    end

    it "accepts awards added via add_award" do
      collection.add_award(second_student_award)
      second_student_items = collection_items.select { |item| item.student_id == second_student_id }
      expect(second_student_items.first.badge_ids).to contain_exactly(1)
    end
  end

  describe "#each" do
    it "emits a value for each supplied status" do
      collection.add_status(first_student_status)
      collection.add_status(second_student_status)

      expect(collection_items.pluck(:student_id)).to match_array [first_student_id, second_student_id]
    end

    it "includes a Set containing badge IDs for each award the student was granted" do
      collection.add_status(first_student_status)
      first_student_awards.each { |award| collection.add_award(award) }

      collection.add_status(second_student_status)
      collection.add_award(second_student_award)

      expect(collection_items.pluck(:badge_ids)).to contain_exactly(Set[1, 2], Set[1])
    end

    describe "status description" do
      it "emits the status description as the status value if one is set" do
        collection.add_status(first_student_status)
        expect(collection_items.pluck(:status_description)).to match_array ["present"]
      end

      it "emits 'unmarked' as the status value if a student has awards with no accompanying attendance status" do
        first_student_awards.each { |award| collection.add_award(award) }

        expect(collection_items.pluck(:status_description)).to match_array ["unmarked"]
      end
    end

    describe "multiple sections" do
      let(:alternate_section_status) { make_status(section_id: 102) }

      it "emits a separate line for each section for a given course/student/teacher/date" do
        collection.add_status(first_student_status)
        collection.add_status(alternate_section_status)

        first_student_items = collection_items.select { |item| item.student_id == first_student_id }
        expect(first_student_items.pluck(:section_id)).to match_array [101, 102]
      end

      it "emits badges for each section for the given course/student/teacher/date" do
        collection.add_status(first_student_status)
        collection.add_status(alternate_section_status)
        first_student_awards.each { |award| collection.add_award(award) }

        first_student_items = collection_items.select { |item| item.student_id == first_student_id }
        expect(first_student_items.pluck(:badge_ids).uniq).to match_array([Set[1, 2]])
      end
    end

    describe "result ordering" do
      it "returns results grouped by date/student/course/teacher, in the order they were added" do
          now = Time.zone.now

          collection.add_status(make_status(class_date: 1.day.ago(now).to_date, student_id: 30, course_id: 400, teacher_id: 101))
          collection.add_status(make_status(class_date: 3.days.ago(now).to_date, student_id: 50, course_id: 404, teacher_id: 105))
          collection.add_status(make_status(class_date: 2.days.ago(now).to_date, student_id: 40, course_id: 401, teacher_id: 103))

          expect(collection_items.pluck(:student_id)).to eq [30, 50, 40]
      end

      it "returns sections in the order they were added within each grouping" do
          now = Time.zone.now

          collection.add_status(make_status(class_date: 3.days.ago(now).to_date, student_id: 50, course_id: 404, teacher_id: 105, section_id: 1))
          collection.add_status(make_status(class_date: 1.day.ago(now).to_date, student_id: 30, course_id: 400, teacher_id: 101, section_id: 2))
          collection.add_status(make_status(class_date: 2.days.ago(now).to_date, student_id: 40, course_id: 401, teacher_id: 103, section_id: 0))
          collection.add_status(make_status(class_date: 1.day.ago(now).to_date, student_id: 30, course_id: 400, teacher_id: 101, section_id: 3))

          expect(collection_items.pluck(:section_id)).to eq [1, 2, 3, 0]
      end
    end

    describe "last_updated_at" do
      let(:now) { Time.zone.now }

      let(:status) { make_status(class_date: now.to_date, updated_at: now, section_id: 101) }
      let(:old_award) { make_award(badge_id: 2, class_date: now.to_date, updated_at: 1.day.ago(now)) }
      let(:new_award) { make_award(class_date: now.to_date, updated_at: 1.day.from_now(now)) }

      it "returns the time the student's attendance for the section was last updated if there are no badges" do
        collection.add_status(status)
        expect(collection_items.first.last_updated_at).to eq status.updated_at
      end

      context "when the student has at least one badge for the current date" do
        it "returns the timestamp of the status if updated more recently than badges" do
          collection.add_status(status)
          collection.add_award(old_award)

          expect(collection_items.first.last_updated_at).to eq status.updated_at
        end

        it "returns the timestamp of the latest badge award if updated more recently than section attendance" do
          collection.add_status(status)
          collection.add_award(old_award)
          collection.add_award(new_award)

          expect(collection_items.first.last_updated_at).to eq new_award.updated_at
        end

        it "calculates timestamps separately for attendance for multiple sections" do
          other_section_status = make_status(
            class_date: now.to_date,
            updated_at: 2.days.from_now(now),
            section_id: 102
          )

          collection.add_status(status)
          collection.add_status(other_section_status)
          collection.add_award(old_award)
          collection.add_award(new_award)

          expect(collection_items.pluck(:section_id, :last_updated_at)).to contain_exactly(
            [101, new_award.updated_at],
            [102, other_section_status.updated_at]
          )
        end
      end
    end
  end
end
