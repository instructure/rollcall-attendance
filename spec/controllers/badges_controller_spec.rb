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

describe BadgesController do
  let(:attributes) { attributes_for(:badge) }
  let(:course_id) { attributes[:course_id] }
  let(:student_id) { attributes[:student_id] }

  before do
    allow(controller).to receive(:require_lti_launch)
    allow(controller).to receive(:request_canvas_authentication)
    allow(controller).to receive(:load_and_authorize_course) { |course_id| Course.new if course_id }
    allow(controller).to receive(:load_and_authorize_account) { |account_id| CachedAccount.new if account_id }
    allow(controller).to receive(:can_grade)
    session[:tool_consumer_instance_guid] = "abc123"
  end

  describe "index" do
    it "finds badges for the course" do
      get :index, params: { course_id: course_id }, format: "json"
      expect(JSON.parse(response.body).class).to eq(Array)
    end

    it "finds badges for the account" do
      get :index, params: { account_id: course_id }, format: "json"
      expect(JSON.parse(response.body).class).to eq(Array)
    end

    it "finds badges for the account" do
      get :index, format: "json"
      expect(response.response_code).to eq(406)
    end
  end

  describe "create" do
    it "creates a new badge for the passed in course" do
      post :create, params: { badge: attributes_for(:badge) }, format: 'json'
      expect(Badge.where(course_id: course_id).count).to eq(1)
    end

    it "does not create a badge when authorization fails" do
      allow(controller).to receive(:load_and_authorize_course) { false }
      post :create, params: { badge: attributes_for(:badge) }, format: 'json'
      expect(Badge.count).to eq(0)
      expect(response.code).to eq('406')
    end
  end

  describe "destroy" do
    let(:badge) { create(:badge, course_id: course_id) }

    it "destroys a badge when the course is authorized" do
      delete :destroy, params: { id: badge.id }, format: :json
      expect(Badge.count).to eq(0)
      expect(response.code).to eq('204')
    end

    it "does not destroy a badge when unauthorized" do
      allow(controller).to receive(:load_and_authorize_course) { false }
      delete :destroy, params: { id: badge.id }, format: :json
      expect(Badge.count).to eq(1)
      expect(response.code).to eq('406')
    end
  end

  describe "update" do
    let(:badge) { create(:badge, course_id: course_id) }

    it "updates a badge assuming the course ID matches that of the logged in user" do
      put :update, params: { id: badge.id, badge: { name: 'new name' } }, format: :json
      expect(badge.reload.name).to eq('new name')
    end

    it "does not update a badge when authorization fails" do
      allow(controller).to receive(:load_and_authorize_course) { false }
      put :update, params: { id: badge.id, badge: { name: 'new name' } }, format: :json
      expect(badge.reload.name).not_to eq('new name')
    end
  end
end
