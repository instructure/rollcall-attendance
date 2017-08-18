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

describe AccountsController do

  before do
    allow(controller).to receive(:require_lti_launch)
    allow(controller).to receive(:request_canvas_authentication)
    allow(controller).to receive(:canvas)
    allow(controller).to receive(:user_id).and_return(2)
    allow(controller).to receive(:can_admin_report)
  end

  describe "show" do
    it "redirects to the new report path" do
      get :show, id: 1
      expect(response).to redirect_to(new_report_path(account_id: 1))
    end
  end

  describe "badges" do
    it 'sends performance metrics to statsd' do
      expect(CanvasStatsd::Statsd).to receive(:timing).with('request.accounts.badges.total', kind_of(Numeric))
      expect(CanvasStatsd::Statsd).to receive(:timing).with('request.accounts.badges.db', kind_of(Numeric))
      expect(CanvasStatsd::Statsd).to receive(:timing).with('request.accounts.badges.view', kind_of(Numeric))
      expect(CanvasStatsd::Statsd).to receive(:timing).with('request.accounts.badges.active_record', kind_of(Numeric))
      expect(CanvasStatsd::Statsd).to receive(:timing).with('request.accounts.badges.sql.read', kind_of(Numeric))
      expect(CanvasStatsd::Statsd).to receive(:timing).with('request.accounts.badges.sql.write', kind_of(Numeric))
      expect(CanvasStatsd::Statsd).to receive(:timing).with('request.accounts.badges.sql.cache', kind_of(Numeric))
      expect(CanvasStatsd::Statsd).to receive(:timing).with('request.accounts.badges.cache.read', kind_of(Numeric))
      get :badges, id: 3
    end

    it "assigns the account id to the controller instance" do
      get :badges, id: 3
      expect(assigns[:account_id]).to eq("3")
    end
  end

end
