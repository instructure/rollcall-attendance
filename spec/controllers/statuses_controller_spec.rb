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

describe StatusesController do
  let(:section) { Section.new(id: 1, students: [{id: 1}]) }
  let(:sections) { [section] }
  let(:user_id) { 5 }

  before do
    allow(controller).to receive(:require_lti_launch)
    allow(controller).to receive(:request_canvas_authentication)
    allow(controller).to receive(:load_and_authorize_full_section) { section }
    allow(controller).to receive(:submit_grade!)
    allow(controller).to receive(:user_id).and_return(user_id)
    allow(controller).to receive(:can_grade)
    session[:tool_consumer_instance_guid] = 'abc123'
  end

  describe "index" do
    it "initializes the list of statuses for the day's section" do
      expect(Status).to receive(:initialize_list).with(section, '2012-08-17', user_id, "abc123")
      get :index, params: { section_id: 1, class_date: '2012-08-17' }, format: :json
    end
  end

  describe "create" do
    let(:course) { Course.new(account_id: 3, id: 1) }

    it "loads and authorizes the course" do
      expect(controller).to receive(:load_and_authorize_course).with('1')
      post :create, params: { status: { course_id: 1 } }, format: :json
    end

    context "with an authorized course" do
      before do
        allow(controller).to receive(:load_and_authorize_course).and_return(course)
      end

      it "sets the account_id of the status to that of the course" do
        post :create, params: { status: attributes_for(:status) }, format: :json
        expect(Status.first.account_id).to eq(3)
      end

      it "posts a grade to canvas" do
        expect(controller).to receive(:submit_grade!)
        post :create, params: { status: attributes_for(:status) }, format: :json
      end

      it "gracefully handles duplicate key errors" do
        post :create, params: { status: attributes_for(:status) }, format: :json
        expect { post :create, params: { status: attributes_for(:status) }, format: :json }.to_not raise_error
      end
    end
  end

  describe "update" do
    it "authorizes the section on the found status" do
      allow(Status).to receive(:find_by) { Status.new(section_id: 1) }
      expect(controller).to receive(:load_and_authorize_section).with(1)
      put :update, params: { id: 1, status: {id: 1} }, format: :json
    end

    it "posts a grade to canvas" do
      allow(controller).to receive(:load_and_authorize_section).and_return(Section.new)
      status = Status.new(section_id: 1)
      allow(Status).to receive(:find_by).and_return(status)
      expect(status).to receive(:save).and_return(true)
      expect(controller).to receive(:submit_grade!).with(status)
      put :update, params: { id: 1, status: {id: 1} }, format: :json
    end
  end

  describe "destroy" do
    it "authorizes the section on the found status" do
      allow(Status).to receive(:find_by) { Status.new(section_id: 1) }
      expect(controller).to receive(:load_and_authorize_section).with(1)
      delete :destroy, params: { id: 1 }
    end

    it "posts a grade to canvas" do
      allow(controller).to receive(:load_and_authorize_section).and_return(Section.new)
      status = double(destroy: true, section_id: 1)
      allow(Status).to receive(:find_by).and_return(status)
      expect(controller).to receive(:submit_grade!).with(status)
      delete :destroy, params: { id: 1 }, format: :json
    end
  end

  describe "submit_grade!" do
    before { allow(controller).to receive(:submit_grade!).and_call_original }

    it "queues up a grade update" do
      expect(Resque).to receive(:enqueue).with(GradeUpdater, kind_of(Hash))
      controller.send(:submit_grade!, Status.new(student_id: 1, section_id: 2, course_id: 3))
    end
  end
end
