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

RSpec.describe StudentStatusesController, type: :controller do
  let(:course_id) { 1 }
  let(:user_id) { 2 }
  let(:jwt_token) do
    controller.encode_jwt({ tool_consumer_instance_guid:  'abc123', course_id: course_id, user_id: user_id })
  end

  before :each do
    allow(controller).to receive(:require_lti_launch)
    allow(controller).to receive(:request_canvas_authentication)
    request.headers['Authorization'] = "Bearer #{jwt_token}"
  end

  describe 'statuses' do
    def response_ids
      json = JSON.parse(response.body)
      json['data'].map { |status| status['id'] }
    end

    let!(:yesterday_status) { create :status, class_date: 1.day.ago, student_id: user_id }
    let!(:today_status) { create :status, class_date: Time.now.utc.to_date, student_id: user_id }

    before :each do
      expect(controller).to receive(:authorize_student).at_least(:once)
    end

    it 'returns a sorted list of statuses for a given student' do
      get :index, params: { course_id: course_id, student_id: user_id }
      expect(response.status).to eql 200
      expect(response_ids).to eql [today_status.id, yesterday_status.id]
    end

    it 'uses attendance_scope to limit returned status to only those with a given attendance value(s)' do
      yesterday_status.update attendance: 'late'
      get :index, params: { course_id: course_id, student_id: user_id, attendance_scope: 'late' }
      expect(response_ids).to eql [yesterday_status.id]

      today_status.update attendance: 'absent'
      get :index, params: { course_id: course_id, student_id: user_id, attendance_scope: %w(late absent) }
      expect(response_ids).to eql [today_status.id, yesterday_status.id]
    end
  end

  describe 'summary' do
    let(:canvas_submission) do
      { 'id' => 123, 'grade' => '95%', 'excused' => false }
    end
    let!(:present_status) { create :status, student_id: user_id, attendance: 'present', class_date: 2.days.ago }
    let!(:late_status) { create :status, student_id: user_id, attendance: 'late', class_date: 1.day.ago }
    let!(:absent_status) { create :status, student_id: user_id, attendance: 'absent' }

    before :each do
      allow(controller).to receive(:cached_submission).with(course_id.to_s, user_id.to_s).and_return(canvas_submission)
      expect(controller).to receive(:authorize_student).at_least(:once)
    end

    it "returns a summary of a student's attendance in a course" do
      get :summary, params: { course_id: course_id, student_id: user_id }
      json = JSON.parse(response.body)
      expected = {
        'present_statuses' => 1,
        'late_statuses' => 1,
        'absent_statuses' => 1,
        'grade' => '95%',
        'tardy_weight' => 0.8
      }
      expect(json).to eql expected
    end
  end
end
