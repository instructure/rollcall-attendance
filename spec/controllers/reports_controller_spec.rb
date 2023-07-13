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

describe ReportsController do
  let(:course_id) { 123 }
  let(:tool_consumer_instance_guid) { 'abc123' }

  let :valid_attrs do
    {
      course_id: course_id,
      email: "foo@bar.com"
    }
  end

  let :course do
    Course.new(id: course_id)
  end

  before do
    canvas = double
    allow(canvas).to receive_messages(get_user_profile: {
      "primary_email" => "foo@bar.com"
    })

    allow(controller).to receive_messages(require_lti_launch: true,
                    request_canvas_authentication: true,
                    load_and_authorize_course: course,
                    canvas: canvas,
                    tool_consumer_instance_guid: 'abc123',
                    can_grade: true)
  end

  describe "Perform GET request on #course" do
    context "the you shouldn't be here path" do
      before { allow(controller).to receive_messages(load_and_authorize_course: nil) }

      it "is not acceptable" do
        get :new, params: { course_id: course_id }
        expect(response.status).to eql(406)
      end

      it "does not assign the user" do
        get :new, params: { course_id: course_id }
        expect(assigns[:user]).to_not be
      end

      it "does not assign the course" do
        get :new, params: { course_id: course_id }
        expect(assigns[:course]).to_not be
      end
    end

    context "the happiest candyland path" do
      it "renders the course report" do
        get :new, params: { course_id: course_id }
        expect(response).to render_template("course")
      end

      it "loads the course" do
        expect(controller).to receive(:load_and_authorize_course).
        with(course_id, tool_consumer_instance_guid).and_return(course)
        get :new, params: { course_id: course_id }
      end

      it "assigns the course" do
        get :new, params: { course_id: course_id }
        expect(assigns[:course]).to eql(course)
      end

      it "assigns the report" do
        get :new, params: { course_id: course_id }
        expect(assigns[:report].course_id).to eql(course_id)
      end

      it "assigns the current user" do
        get :new, params: { course_id: course_id }
        expect(assigns[:user]['primary_email']).to eql("foo@bar.com")
      end
    end
  end

  describe "Perform GET request on #account" do
    context "#get_account" do
      let(:redis) { $REDIS }
      let(:account_id) { 1 }
      let(:canvas) {double(:canvas_api)}

      before do
        allow(controller).to receive(:load_and_authorize_account) { CachedAccount.new }
      end

      it "does not call the canvas api if chached" do
        allow(redis).to receive(:get).and_return('{"id":1, "name":"School Name"}')
        expect(canvas).not_to receive(:get_account)
        get :new, params: { account_id: account_id }
      end

      it "fetches from api if not cached" do
        allow(redis).to receive(:get).and_return(nil)
        allow(controller).to receive(:get_account).and_return({"id" => 1, "name" => "School Name" })

        get :new, params: { account_id: account_id }
      end
    end
  end

  describe "Perform POST request on #create" do
    after(:each) do
      $REDIS.del("abc123:report:0:foo@bar.com::")
    end

    it "generates a report for the given course" do
      expect(Resque).to receive(:enqueue).with(AttendanceReportGenerator, kind_of(Hash))
      post :create, params: { course_id: course_id, report: valid_attrs }
    end

    it "sets the flash notice" do
      post :create, params: { course_id: course_id, report: valid_attrs }
      expect(flash[:notice]).to eql("Thank you, your report should arrive in your inbox shortly.")
    end

    it "not generate a report with an existing cache with key/value" do
      post :create, params: { course_id: course_id, report: valid_attrs }

      post :create, params: { course_id: course_id, report: valid_attrs }
      expect(flash[:notice]).to eql("Your report is already being processed.")
    end
  end
end
