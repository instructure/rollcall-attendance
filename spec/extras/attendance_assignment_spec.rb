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

describe AttendanceAssignment do
  let(:canvas) { double(canvas_url: "http://localhost:3000") }
  let(:course_id) { 1 }
  let(:launch_url) { 'http://localhost:3001' }
  subject(:attendance_assignment) { AttendanceAssignment.new(canvas, course_id, launch_url) }

  its(:canvas) { should == canvas }
  its(:course_id) { should == course_id }

  describe "fetch_or_create" do
    it "returns the assignment ID from cache if possible" do
      allow(attendance_assignment).to receive(:fetch_from_cache).and_return(123)
      expect(attendance_assignment.send(:fetch_or_create)).to eq(123)
    end

    it "returns the assignment ID from fetch if not in cache" do
      allow(attendance_assignment).to receive(:fetch_from_cache).and_return(nil)
      allow(attendance_assignment).to receive(:fetch).and_return({ 'id' => 123 })
      expect(attendance_assignment.send(:fetch_or_create)).to eq(123)
    end

    it "doesn't choke on nil" do
      allow(attendance_assignment).to receive(:fetch_from_cache).and_return(nil)
      allow(attendance_assignment).to receive(:fetch).and_return(nil)
      allow(attendance_assignment).to receive(:create).and_return(nil)
      expect(attendance_assignment.send(:fetch_or_create)).to be_nil
    end
  end

  describe "fetch" do
    it "finds the assignment with the name of 'Roll Call Attendance'" do
      allow(canvas).to receive(:get_assignments).and_return(
        [{'name' => 'assignment1', 'id' => '1'}, {'name' => 'Roll Call Attendance', 'id' => '2'}]
      )

      expect(attendance_assignment.fetch['id']).to eq('2')
    end
  end

  describe "fetch_from_cache" do
    it "verifies the cached assignment" do
      redis = double()
      allow(redis).to receive(:get).and_return('1')
      allow(redis).to receive(:set)
      allow(attendance_assignment).to receive(:redis).and_return(redis)
      allow(canvas).to receive(:get_assignment).and_return(
        {'name' => 'Roll Call Attendance', 'id' => '2'}
      )

      expect(attendance_assignment.fetch_or_create).to eq('1')
    end

    it "returns nil if cache returns empty string" do
      redis = double()
      allow(redis).to receive(:get).and_return("")
      allow(attendance_assignment).to receive(:redis).and_return(redis)

      expect(attendance_assignment.fetch_from_cache).to be_nil
    end

    it "returns nil if cache returns nil" do
      redis = double()
      allow(redis).to receive(:get).and_return(nil)
      allow(attendance_assignment).to receive(:redis).and_return(redis)

      expect(attendance_assignment.fetch_from_cache).to be_nil
    end
  end

  describe "create" do
    it "posts a request to canvas to create a roll call assignment for the current course" do
      expected_assignment_params = {
        name: 'Roll Call Attendance',
        grading_type: "percent",
        points_possible: 100,
        published: true,
        submission_types: ['external_tool'],
        external_tool_tag_attributes: {
          url: launch_url,
          new_tab: false
        }
      }
      expect(canvas).to receive(:create_assignment).with(1, expected_assignment_params)
      attendance_assignment.create
    end
  end

  describe "submit_grade" do
    before do
      allow(StudentCourseStats).to receive_message_chain(:new, :grade) { '75%' }
    end

    it "grades the assignment through canvas" do
      expect(canvas).to receive(:grade_assignment).with(course_id, 'assignment id', 'student id',
        submission: { posted_grade: '75%', submission_type: 'basic_lti_launch', url: 'http://localhost:3001' })
      attendance_assignment.submit_grade('assignment id', 'student id', 'section id', 'abc123')
    end

    it "fails gracefully when the user is not authorized to update grades" do
      expect(canvas).to receive(:grade_assignment).and_raise(CanvasOauth::CanvasApi::Unauthorized)
      expect { attendance_assignment.submit_grade('assignment id', 'student id', 'section id', 'abc123') }.to_not raise_error
    end
  end
end
