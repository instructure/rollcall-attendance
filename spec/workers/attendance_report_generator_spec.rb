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

describe AttendanceReportGenerator do
  describe "perform" do
    let(:user_id) { 1 }
    let(:account_id) { 2 }
    let(:canvas_url) { 'http://test.canvas' }
    let(:email) { 'user@school.edu' }
    let(:tool_consumer_instance_guid) { 'abc123' }
    let(:filters) { {} }

    let(:valid_params) {
      {
        'canvas_url' => canvas_url,
        'user_id' => user_id,
        'email' => email,
        'account_id' => account_id,
        'tool_consumer_instance_guid' => tool_consumer_instance_guid,
        'filters' => filters
      }
    }

    before do
      AWS.stub!

      allow(CanvasOauth::CanvasApi).to receive(:new)
      allow(AttendanceReport).to receive(:new).and_return(double(to_csv: "csv data"))
      allow(ReportMailer).to receive_message_chain(:attendance_report, :deliver_now)
    end

    it "creates a new Canvas instance using the token associated with the passed in user ID" do
      expect(CanvasOauth::CanvasApi).to receive(:new).with(canvas_url, 'token', anything(), anything())
      allow(CanvasOauth::Authorization).to receive(:fetch_token).with(user_id, tool_consumer_instance_guid).and_return('token')
      AttendanceReportGenerator.perform(valid_params)
    end

    it "creates an attendance report" do
      canvas = double
      allow(CanvasOauth::CanvasApi).to receive(:new) { canvas }
      expect(AttendanceReport).to receive(:new).with(canvas, valid_params)
      AttendanceReportGenerator.perform(valid_params)
    end

    it "sends an attendance report mailer" do
      allow(AttendanceReportGenerator).to receive(:s3_url).and_return('http://foobar.com/file.csv')
      expect(ReportMailer).to receive(:attendance_report).with(email, "http://foobar.com/file.csv", nil)
      AttendanceReportGenerator.perform(valid_params)
    end

    it "sends along SIS error messages to the user" do
      report = double
      expect(report).to receive(:to_csv).and_raise(AttendanceReport::SisFilterNotFound)
      allow(AttendanceReport).to receive(:new).and_return(report)
      expect(ReportMailer).to receive(:attendance_report).with(email, nil, "AttendanceReport::SisFilterNotFound")
      AttendanceReportGenerator.perform(valid_params)
    end

    it "raises an exception when a field is missing" do
      invalid_params = valid_params
      invalid_params[:canvas_url] = ''
      expect { AttendanceReportGenerator(invalid_params) }.to raise_error(NoMethodError)
    end
  end
end
