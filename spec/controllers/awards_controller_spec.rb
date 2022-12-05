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

describe AwardsController do
  let(:attributes) { attributes_for(:award) }
  let(:course_id) { attributes[:course_id] }
  let(:student_id) { attributes[:student_id] }
  let(:teacher_id) { attributes[:teacher_id] }
  let(:tool_consumer_instance_guid) { attributes[:tool_consumer_instance_guid] }

  before do
    allow(controller).to receive(:require_lti_launch)
    allow(controller).to receive(:request_canvas_authentication)
    allow(controller).to receive(:load_and_authorize_course).and_return(Course.new)
    allow(controller).to receive(:user_id).and_return(teacher_id)
    allow(controller).to receive(:can_grade)
    session[:tool_consumer_instance_guid] = tool_consumer_instance_guid
  end

  describe "index" do
    it "builds a list of awards for the student" do
      course3 = Course.new(:id => course_id)
      expect(controller).to receive(:load_and_authorize_course).with(course_id).and_return(course3)
      expect(Award).to receive(:build_list_for_student).with(course3, student_id, '2012-08-02', teacher_id, tool_consumer_instance_guid)
      get :index, params: { student_id: student_id, course_id: course_id, class_date: '2012-08-02' }, format: 'json'
    end
  end

  describe "create" do
    it "creates a new award for the current course" do
      post :create, params: { award: attributes_for(:award) }, format: 'json'
      expect(Award.where(course_id: course_id, tool_consumer_instance_guid: tool_consumer_instance_guid).count).to eq(1)
    end
  end

  describe "destroy" do
    it "destroys an award assuming the course authorization passes" do
      award = create(:award, course_id: course_id)
      delete :destroy, params: { id: award.id }, format: :json
      expect(Award.count).to eq(0)
    end

    it "does not destroy an award when course authorization doesn't return success" do
      allow(controller).to receive(:load_and_authorize_course).and_return(false)
      award = create(:award, course_id: 100)
      delete :destroy, params: { id: award.id }, format: :json
      expect(Award.count).to eq(1)
    end
  end

  describe "stats" do
    it "calls student_stats" do
      expect(Award).to receive(:student_stats).with(course_id.to_s, student_id.to_s, tool_consumer_instance_guid)
      get :stats, params: { course_id: course_id, student_id: student_id }, format: 'json'
    end
  end
end
