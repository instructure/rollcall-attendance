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
end
