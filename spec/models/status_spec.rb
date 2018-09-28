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

describe Status do
  it { is_expected.to validate_presence_of(:section_id) }
  it { is_expected.to validate_presence_of(:student_id) }
  it { is_expected.to validate_presence_of(:teacher_id) }
  it { is_expected.to validate_presence_of(:class_date) }
  it { is_expected.to validate_presence_of(:attendance) }
  it { is_expected.to validate_presence_of(:course_id) }
  it { is_expected.to validate_presence_of(:account_id) }

  describe '#initialize_list' do
    let(:section) {
      section = Section.new(id: 1, name: 'a section')
      section.students = [student1, student2]
      section
    }

    let(:student1) { Student.new(id: 1, name: 'student 1', avatar_url: 'avatar1') }
    let(:student2) { Student.new(id: 2, name: 'student 2', avatar_url: 'avatar2') }
    let(:teacher_id) { 5 }
    let(:tool_consumer_instance_guid) { "abc123" }

    subject(:list) { Status.initialize_list(section, Time.now.utc.to_date, teacher_id, tool_consumer_instance_guid) }

    it 'queries the Status table for statuses in this section for the current date' do
      expect(Status).to receive(:existing_for_section_and_date).with(
        section,
        Time.now.utc.to_date,
        tool_consumer_instance_guid
      ).and_return([])
      list
    end

    it 'returns a number of statuses equal to the number of students' do
      expect(list.size).to eq(section.students.size)
    end

    it 'sets the student names' do
      expect(list.map(&:student).map(&:name).sort).to eq(['student 1', 'student 2'])
    end

    it 'sets the student avatar urls' do
      expect(list.map(&:student).map(&:avatar_url).sort).to eq(['avatar1', 'avatar2'])
    end

    it "doesn't include students who are not in the list (removed from the class roster)" do
      create(:status, section_id: 1, class_date: Time.now.utc.to_date, student_id: 3, teacher_id: 5, tool_consumer_instance_guid: tool_consumer_instance_guid)
      expect(list.map(&:student)).to eq([student1, student2])
    end
  end

  describe '#key_list_by_student_id' do
    let(:status1) { double(student_id: 1) }
    let(:status2) { double(student_id: 2) }
    let(:list) { [status1, status2] }
    subject(:hash) { Status.key_list_by_student_id(list) }

    specify { expect(hash[1]).to eq(status1) }
    specify { expect(hash[2]).to eq(status2) }
    its(:length) { should == 2 }
  end

  describe "#as_json" do
    let(:section) do
      section = Section.new(id: 1, name: 'a section')
      section.students = [student]
      section
    end
    let(:student) { Student.new(id: 12345, name: 'Student') }
    let(:teacher) { Student.new(id: 56789, name: 'Teacher') }
    let(:status) do
      Status.initialize_list(section, Time.now.utc.to_date, teacher.id, tool_consumer_instance_guid)
    end
    let(:tool_consumer_instance_guid) { "abc123" }

    it "returns the student_id as a string" do
      expect(status.as_json.first[:student_id]).to eq student.id.to_s
    end

    it "returns the teacher_id as a string" do
      expect(status.as_json.first[:teacher_id]).to eq teacher.id.to_s
    end
  end
end
