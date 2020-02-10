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
  context(:update) do
    let(:cid) { 1 }
    let(:guid) { "guid" }

    before do
      CourseConfig.create!(
        course_id: cid,
        tool_consumer_instance_guid: guid,
        omit_from_final_grade: true
      )
    end

    it "should try to update the assignment" do
      canvas = double()
      assign = AttendanceAssignment.new(canvas, cid, "url", guid)
      assign_hashes = [{
        'id' => 45,
        'name' =>  "Roll Call Attendance",
        'omit_from_final_grade' => false
      }]
      expect(canvas).to receive(:get_assignments).with(cid).and_return(assign_hashes)
      expect(canvas).to receive(:update_assignment).with(cid, 45, { omit_from_final_grade: true })
      assign.fetch
    end

    it "should not try to update the assignment if not needed" do
      canvas = double()
      assign = AttendanceAssignment.new(canvas, cid, "url", guid)
      assign_hashes = [{
        'id' => 45,
        'name' =>  "Roll Call Attendance",
        'omit_from_final_grade' => true
      }]
      expect(canvas).to receive(:get_assignments).with(cid).and_return(assign_hashes)
      expect(canvas).not_to receive(:update_assignment).with(cid, 45, { omit_from_final_grade: true })
      assign.fetch
    end

    it "should not try to update the assignment if explicitly asked not to" do
      canvas = double()
      assign = AttendanceAssignment.new(canvas, cid, "url", guid)
      assign_hashes = [{
        'id' => 45,
        'name' =>  "Roll Call Attendance",
        'omit_from_final_grade' => false
      }]
      expect(canvas).to receive(:get_assignments).with(cid).and_return(assign_hashes)
      expect(canvas).not_to receive(:update_assignment).with(cid, 45, { omit_from_final_grade: true })
      assign.fetch(try_update: false)
    end
  end
end
