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
require 'health_check'

describe HomeController do
  describe 'health_check' do

    it "returns 200  under normal circumstances" do
      get :health_check
      expect(response.body).to eq('ok')
      expect(response.status).to eq(200)
    end

    it "returns a 500 under unhealthy circumstances" do
      allow_any_instance_of(HealthCheck).to receive(:healthy?).and_return(false)
      get :health_check
      expect(response.body).to eq('down')
      expect(response.status).to eq(500)
    end

  end

  describe 'liveness' do
    it 'returns a JSON in a specific format' do
      get:liveness

      expect(response.status). to eq(200)

      json_response = JSON.parse(response.body, symbolize_name:true)

      json_response['message'].should == ('ok' || 'down')
    end
  end

  describe 'readiness' do
    let(:method) { [ReadinessCheck::RedisReadinessCheck::Redis, 
      ReadinessCheck::ResqueReadinessCheck::ResqueJobs]}

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

    it 'returns 503 if unhealthy' do
      allow(controller).to receive(:app_healthy?).and_return(false)
      get :readiness
      expect(response).to have_http_status(:service_unavailable)
    end

    it 'returns 200 if healthy' do
      allow(controller).to receive(:app_healthy?).and_return(true)
      get :readiness
      expect(response).to have_http_status(:ok)
    end

    it 'returns 200 if components are healthy' do
      allow(ReadinessCheck::RedisReadinessCheck::Redis).to receive(:method).and_return(true)
      allow(ReadinessCheck::ResqueReadinessCheck::ResqueJobs).to receive(:method).and_return(true)

      get :readiness
      expect(response).to have_http_status(:ok)
    end

    it 'returns 503 if components are unhealthy' do
      allow(ReadinessCheck::RedisReadinessCheck::Redis).to receive(:method).and_return(false)
      allow(ReadinessCheck::ResqueReadinessCheck::ResqueJobs).to receive(:method).and_return(false)
      allow(controller).to receive(:status_unhealthy?).and_return(true)

      get :readiness
      expect(JSON.parse(response.body, symbolize_name:true)['status']).to eq(503)
    end

  end
end
