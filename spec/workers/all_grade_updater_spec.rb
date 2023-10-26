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
    let(:section_id) { 1 }
    let(:student_ids) { [2] }
    let(:canvas_assignment) { { 'id' => 3, 'omit_from_final_grade' => false } }
    let(:tci_guid) { 'abc123' }

    it "submits grades for all students in all sections" do
      assignment = double(fetch_or_create: canvas_assignment)
      expect(assignment).to receive(:submit_grades).
        with(canvas_assignment['id'], student_ids)
      allow(AttendanceAssignment).to receive(:new).and_return(assignment)

      AllGradeUpdater.perform(
        canvas_url: 'http://test.canvas',
        user_id: 1,
        student_ids: student_ids,
        course_id: 4,
        tool_consumer_instance_guid: tci_guid
      )
    end
  end
end
