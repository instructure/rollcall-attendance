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

describe CourseConfigsController do
  let(:section) { Section.new(id: 1, students: [{id: 1}, {id: 2}]) }
  let(:sections) { [section] }
  let(:user_id) { 5 }
  let(:tci_guid) { 'abc123' }

  before do
    allow(controller).to receive(:require_lti_launch)
    allow(controller).to receive(:request_canvas_authentication)
    allow(controller).to receive(:load_and_authorize_sections) { sections }
    allow(controller).to receive(:resubmit_all_grades!)
    allow(controller).to receive(:authorized_to_update_config?).and_return(true)
    allow(controller).to receive(:user_id).and_return(user_id)
    allow(controller).to receive(:can_grade)
    session[:tool_consumer_instance_guid] = tci_guid
  end

  describe "update" do
    let(:cc) {
      CourseConfig.new(course_id: 3, tool_consumer_instance_guid: tci_guid)
    }

    before do
      allow(CourseConfig).to receive(:find_by) { cc }
    end

    it "updates grades and saves when the tardy weight changes" do
      expect(controller).to receive(:resubmit_all_grades!).with(cc)
      put :update, params: { id: 1, course_config: { tardy_weight: 0.63 } }, format: :json
    end

    it "just saves when the tardy weight is blank" do
      expect(controller).not_to receive(:resubmit_all_grades!)
      put :update, params: { id: 1, course_config: {} }, format: :json
    end

    it "updates the canvas assignment when course config params include omit_from_final_grade" do
      params = {
        canvas_url: nil,
        course_id: 3,
        options: {omit_from_final_grade: false},
        tool_consumer_instance_guid: "abc123",
        tool_launch_url: "http://test.host/launch",
        user_id: 5
      }
      expect(Resque).to receive(:enqueue).with(CanvasAssignmentUpdater, params)
      put :update, params: {id: 1, course_config: {omit_from_final_grade: false}}, format: :json
    end

    it "does not update the canvas assignment when course config params does not include omit_from_final_grade" do
      expect(Resque).not_to receive(:enqueue).with(CanvasAssignmentUpdater, any_args)
      put :update, params: {id: 1, course_config: {}}, format: :json
    end
  end

  describe "resubmit_all_grades!" do
    let(:course_id) { 3 }
    before { allow(controller).to receive(:resubmit_all_grades!).and_call_original }

    it "queues up an all grade update" do
      grade_params = {
        canvas_url: nil,
        user_id: user_id,
        course_id: course_id,
        student_ids: [1, 2],
        tool_consumer_instance_guid: tci_guid
      }
      expect(Resque).to receive(:enqueue).with(AllGradeUpdater, hash_including(grade_params))
      controller.send(:resubmit_all_grades!, CourseConfig.new(course_id: course_id))
    end
  end
end
