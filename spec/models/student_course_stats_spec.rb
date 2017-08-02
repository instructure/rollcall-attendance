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

describe StudentCourseStats do
  describe "initializer" do
    subject { StudentCourseStats.new(1, 1, 123, 'abc123') }

    its(:student_id) { should == 1 }
    its(:course_id) { should == 1 }
    its(:section_id) { should == 123 }
    its(:tool_consumer_instance_guid) { should == 'abc123' }
  end

  describe "attendance_count" do
    let(:student_id) { 1 }
    let(:course_id) { 2 }
    let(:section_id) { 3 }
    let(:tci_guid) { "abc123" }

    subject { StudentCourseStats.new(student_id, course_id, section_id, tci_guid) }

    before do
      create(:status,
             student_id: student_id,
             course_id: course_id,
             section_id: section_id,
             class_date: 1.minute.ago,
             attendance: 'present',
             tool_consumer_instance_guid: tci_guid)
      create(:status,
             student_id: student_id,
             course_id: course_id,
             section_id: section_id,
             class_date: 1.day.ago,
             attendance: 'absent',
             tool_consumer_instance_guid: tci_guid)

      # for another student
      create(:status,
             student_id: 0,
             course_id: course_id,
             section_id: section_id,
             class_date: 1.minute.ago,
             attendance: 'present',
             tool_consumer_instance_guid: tci_guid)
      # for another course
      create(:status,
             student_id: student_id,
             course_id: 0,
             section_id: 0,
             class_date: 1.minute.ago,
             attendance: 'present',
             tool_consumer_instance_guid: tci_guid)
    end

    specify { expect(subject.attendance_count).to eq(2) }
    specify { expect(subject.attendance_count('present')).to eq(1) }
    specify { expect(subject.attendance_count('late')).to eq(0) }
    specify { expect(subject.attendance_count('absent')).to eq(1) }
  end

  describe "score" do
    let(:student_id) { 1 }
    let(:course_id) { 2 }
    let(:section_id) { 3 }
    let(:tci_guid) { "abc123" }
    let(:stats) { StudentCourseStats.new(student_id, course_id, section_id, tci_guid) }

    subject { stats.score }

    before do
      allow(stats).to receive(:attendance_count).and_return(10)
      allow(stats).to receive(:attendance_count).with('present').and_return(8)
      allow(stats).to receive(:attendance_count).with('late').and_return(1)
      allow(stats).to receive(:tardy_weight).and_return(0.8)
    end

    context "with the default late period weight" do
      it { is_expected.to eq((8 + 0.8) / 10.0) }
    end
  end

  describe "grade" do
    let(:stats) { StudentCourseStats.new(1, 1, 1, 'abc123') }

    it "returns a string when score returns a score" do
      allow(stats).to receive(:score).and_return(0.8)
      expect(stats.grade).to eq("80%")
    end

    it "returns nil when score is nil" do
      allow(stats).to receive(:score).and_return(nil)
      expect(stats.grade).to be_nil
    end
  end
end
