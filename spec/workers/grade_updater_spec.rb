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

describe GradeUpdater do
  describe "perform" do
    let(:canvas_assignment) { { 'id' => 5, 'omit_from_final_grade' => false } }
    let(:student_id) { 2 }
    let(:section_id) { 3 }
    let(:tci_guid) { 'abc123' }

    it "submits a grade for the found assignment given the passed in params" do
      assignment = double(fetch_or_create: canvas_assignment)
      expect(assignment).to receive(:get_student_grade).
        with(student_id)
      expect(assignment).to receive(:submit_grade).
        with(canvas_assignment['id'], student_id)
      allow(AttendanceAssignment).to receive(:new).and_return(assignment)

      GradeUpdater.perform(
        canvas_url: 'http://test.canvas',
        user_id: 1,
        student_id: student_id,
        course_id: 4,
        tool_consumer_instance_guid: tci_guid
      )
    end
  end
end
