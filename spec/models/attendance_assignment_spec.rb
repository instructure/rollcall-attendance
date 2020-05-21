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
  describe "#fetch" do
    let(:canvas_assign) { {"id" => 45, "name" => "Roll Call Attendance", "omit_from_final_grade" => false } }
    let(:assign_hashes) { [canvas_assign] }
    let(:canvas) { double("canvas double", canvas_url: "url") }
    let(:cid) { 1 }
    let(:guid) { "guid" }

    before do
      @course_config = CourseConfig.create!(
        course_id: cid,
        tool_consumer_instance_guid: guid,
        omit_from_final_grade: true
      )
    end

    context "when try_update is true" do
      let(:attendance_assignment) { AttendanceAssignment.new(canvas, cid, "url", "guid") }

      before do
        # Populate the cache with an outdated value
        attendance_assignment.cache_assignment(
          canvas_assign.merge({"omit_from_final_grade" => true}).to_json
        )

        allow(canvas).to receive(:get_assignments).with(cid).and_return(assign_hashes)
      end

      it "updates the cached assignment if the given assignment's omit_from_final_grade differs" do
        expect {
          attendance_assignment.fetch(try_update: true)
        }.to change {
          attendance_assignment.fetch_from_cache["omit_from_final_grade"]
        }.from(true).to(false)
      end

      it "updates the CourseConfig if the given assignment's omit_from_final_grade differs" do
        expect {
          attendance_assignment.fetch(try_update: true)
        }.to change {
          @course_config.reload.omit_from_final_grade
        }.from(true).to(false)
      end
    end

    context "when try_update is false" do
      let(:attendance_assignment) { AttendanceAssignment.new(canvas, cid, "url", "guid") }

      before do
        # Populate the cache with an outdated value
        attendance_assignment.cache_assignment(
          canvas_assign.merge({"omit_from_final_grade" => true}).to_json
        )

        allow(canvas).to receive(:get_assignments).with(cid).and_return(assign_hashes)
      end

      it "does not update the cached assignment if the given assignment's omit_from_final_grade differs" do
        expect {
          attendance_assignment.fetch(try_update: false)
        }.not_to change {
          attendance_assignment.fetch_from_cache["omit_from_final_grade"]
        }
      end

      it "does not update the CourseConfig if the given assignment's omit_from_final_grade differs" do
        expect {
          attendance_assignment.fetch(try_update: false)
        }.not_to change {
          @course_config.reload.omit_from_final_grade
        }
      end
    end
  end
end
