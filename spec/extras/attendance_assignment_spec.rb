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
  let(:tool_consumer_instance_guid) { "canvas:rules1234"}
  subject(:attendance_assignment) { AttendanceAssignment.new(canvas, course_id, launch_url, tool_consumer_instance_guid) }

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
      expect(attendance_assignment.send(:fetch_or_create)).to eq({ 'id' => 123 })
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
      allow(redis).to receive(:get).and_return({ 'id'=> '1', 'omit_from_final_grade' => false }.to_json)
      allow(redis).to receive(:set)
      allow(attendance_assignment).to receive(:redis).and_return(redis)
      allow(canvas).to receive(:get_assignment).and_return(
        {'name' => 'Roll Call Attendance', 'id' => '2'}
      )

      expect(attendance_assignment.fetch_or_create).to eq({ 'id'=> '1', 'omit_from_final_grade' => false })
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
        },
        omit_from_final_grade: false
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
      allow(canvas).to receive(:get_sections).with(course_id).and_return([{ "id" => 1 }])
      expect(canvas).to receive(:grade_assignment).with(course_id, 'assignment id', 'student id',
        submission: { posted_grade: '75%', submission_type: 'basic_lti_launch', url: 'http://localhost:3001' })
      attendance_assignment.submit_grade('assignment id', 'student id')
    end

    it "updates an unmarked grade in canvas" do
      allow(StudentCourseStats).to receive_message_chain(:new, :grade) { '' }
      allow(canvas).to receive(:get_sections).with(course_id).and_return([{ "id" => 1 }])
      expect(canvas).to receive(:grade_assignment).with(course_id, 'assignment id', 'student id',
        submission: { posted_grade: '', submission_type: 'basic_lti_launch', url: 'http://localhost:3001' })
      attendance_assignment.submit_grade('assignment id', 'student id')
    end

    it "fails gracefully when the user is not authorized to update grades" do
      allow(canvas).to receive(:get_sections).with(course_id).and_return([{ "id" => 1 }])
      expect(canvas).to receive(:grade_assignment).and_raise(CanvasOauth::CanvasApi::Unauthorized)
      expect { attendance_assignment.submit_grade('assignment id', 'student id')}.to_not raise_error
    end
  end

  describe "active_section_ids" do
    it "returns a list of section ids from canvas" do
      allow(canvas).to receive(:get_sections).with(course_id).and_return([{"id" => 1}, {"id" => 3}])
      expect(attendance_assignment.active_section_ids).to eq([1, 3])
    end
  end

  describe "update_if_needed" do

    let!(:course_config) {
      CourseConfig.create!(
        course_id: course_id,
        tool_consumer_instance_guid: tool_consumer_instance_guid,
        omit_from_final_grade: true
      )
    }

    let(:assignment) { { 'id' => '123', 'omit_from_final_grade' => true} }

    it "returns nil if no assignment is passed in" do
      expect(attendance_assignment.update_if_needed(assignment: nil)).to be_nil
    end

    it "doesn't update the assignment in canvas if canvas and course config omit_from_final_grade matches" do
      expect(canvas).not_to receive(:update_assignment)

      attendance_assignment.update_if_needed(assignment: assignment)
    end

    it "returns the assignment when it doesn't update" do
      expect(canvas).not_to receive(:update_assignment)

      expect(attendance_assignment.update_if_needed(assignment: assignment)).to eq(assignment)
    end

    it "doesn't update canvas if assignment is missing omit_from_final_grade and course config's is false" do
      course_config.update!(omit_from_final_grade: false)
      expect(canvas).not_to receive(:update_assignment)

      attendance_assignment.update_if_needed(assignment: { 'id' => '123' })
    end

    it "updates the assignment in canvas if course config and canvas omit_from_final_grade differs" do
      expect(canvas).to receive(:update_assignment).with(course_id, '123', { omit_from_final_grade: true })

      assignment['omit_from_final_grade'] = false
      attendance_assignment.update_if_needed(assignment: assignment)
    end

    it "returns the assignment when it updates" do
      assignment['omit_from_final_grade'] = false
      allow(canvas).to receive(:update_assignment).with(course_id, '123', { omit_from_final_grade: true }).and_return(assignment)

      expect(attendance_assignment.update_if_needed(assignment: assignment)).to eq(assignment)
    end

    it "doesn't updates the cache when not specified" do
      expect(canvas).to receive(:update_assignment).with(course_id, '123', { omit_from_final_grade: true })
      redis = double();
      allow(attendance_assignment).to receive(:redis).and_return(redis)
      expect(redis).not_to receive(:set)

      attendance_assignment.update_if_needed(assignment: { 'id' => '123', 'omit_from_final_grade' => false })
    end

    it "updates the cache when specified" do
      expect(canvas).to receive(:update_assignment).with(course_id, '123', { omit_from_final_grade: true })
      redis = double();
      allow(attendance_assignment).to receive(:redis).and_return(redis)

      updated_assignment = { 'id' => '123', 'omit_from_final_grade' => true }

      allow(canvas).to receive(:update_assignment).and_return(updated_assignment)

      expect(redis).to receive(:set).with(attendance_assignment.cache_key, updated_assignment.to_json, ex: 900)
      attendance_assignment.update_if_needed(assignment: { 'id' => '123', 'omit_from_final_grade' => false },
        update_cache: true)
    end
  end
end
