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

describe HomeController do

  describe 'liveness' do
    it 'returns 200 if healthy' do
      allow(controller).to receive(:app_healthy?).and_return(true)
      get:liveness

      expect(response).to have_http_status(:ok)
    end

    it 'returns 500 if healthy' do
      allow(controller).to receive(:app_healthy?).and_return(false)
      get:liveness

      expect(response).to have_http_status(:service_unavailable)
    end
  end

  describe 'readiness' do
    let(:method) { [ReadinessCheck::Redis,
      ReadinessCheck::ResqueJobs]}

    it 'returns a JSON in a specific format' do
      allow(controller).to receive(:app_healthy?).and_return(true)

      get:readiness

      json_response = JSON.parse(response.body, symbolize_name:true)

      expect(json_response['status'].class).to eq(Integer)
      expect(json_response['components'][0]['name'].class).to eq(String)
      expect(json_response['components'][0]['status'].class).to eq(Integer)
      expect(json_response['components'][0]['message'].class).to eq(String)
      expect(json_response['components'][0]['response_time_ms'].class).to eq(Float)
    end

    it 'returns 200 if healthy' do
      allow(controller).to receive(:app_healthy?).and_return(true)
      allow(controller).to receive(:status_unhealthy?).and_return(false)

      get :readiness
      expect(response).to have_http_status(:ok)
    end

    it 'returns 503 if unhealthy' do
      allow(controller).to receive(:app_healthy?).and_return(false)
      get :readiness
      expect(response).to have_http_status(:service_unavailable)
    end

    it 'returns 200 if components are healthy' do
      allow(controller).to receive(:app_healthy?).and_return(true)
      allow(controller).to receive(:status_unhealthy?).and_return(false)
      allow(ReadinessCheck::Redis).to receive(:method).and_return(true)
      allow(ReadinessCheck::ResqueJobs).to receive(:method).and_return(true)

      get :readiness
      expect(response).to have_http_status(:ok)
    end

    it 'returns 503 if components are unhealthy' do
      allow(ReadinessCheck::Redis).to receive(:method).and_return(false)
      allow(ReadinessCheck::ResqueJobs).to receive(:method).and_return(false)
      allow(controller).to receive(:app_healthy?).and_return(true)
      allow(controller).to receive(:status_unhealthy?).and_return(true)

      get :readiness
      expect(JSON.parse(response.body, symbolize_name:true)['status']).to eq(503)
    end

  end
end
