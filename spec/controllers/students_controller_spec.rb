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

RSpec.describe StudentsController, type: :controller do
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

  describe 'show' do
    it 'renders a show template' do
      expect(controller).to receive(:load_and_authorize_student).with(course_id.to_s, user_id.to_s).and_return(true)
      get :show, params: { course_id: course_id, id: user_id }
      expect(response).to render_template 'students/show'
    end
  end
end
