#
# Copyright (C) 2020 - present Instructure, Inc.
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

describe CanvasAssignmentUpdater do
  describe ".perform" do
    let(:canvas) { double("canvas double", canvas_url: "canvas_url") }
    let(:canvas_assignment) { { 'id' => 3, 'omit_from_final_grade' => false } }
    let(:params) do
      {
        canvas_url: "canvas_url",
        course_id: "12",
        options: {omit_from_final_grade: false},
        tool_consumer_instance_guid: "abc123",
        tool_launch_url: "launch_url",
        user_id: "1"
      }
    end

    before do
      allow(CanvasOauth::CanvasApiExtensions).to receive(:build).and_return(canvas)
      allow(canvas).to receive(:update_assignment).and_return(canvas_assignment)
    end

    it "calls AttendanceAssignment#update_cached_assignment_if_needed" do
      attendance_assignment = AttendanceAssignment.new(
        canvas,
        params[:course_id],
        params[:canvas_url],
        params[:tool_consumer_instance_guid]
      )

      allow(AttendanceAssignment).to receive(:new).and_return(attendance_assignment)
      allow(attendance_assignment).to receive(:fetch_or_create).and_return(canvas_assignment)
      expect(attendance_assignment).to receive(:update_cached_assignment_if_needed).with(canvas_assignment)
      CanvasAssignmentUpdater.perform(params)
    end
  end
end
