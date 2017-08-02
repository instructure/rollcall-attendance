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

describe CanvasCache do
  let(:object) { Object.new }
  before {
    object.extend(CanvasCache)
    allow(object).to receive(:tool_consumer_instance_guid).and_return('abc123')
  }

  describe "cache_response" do
    it "sets the response in redis as JSON" do
      response = { hash: "value" }
      object.cache_response("key", response)
      expect(object.redis.get('key')).to eq(response.to_json)
    end
  end

  describe "cached_response" do
    let(:request) { lambda { { 'source' => 'lambda' } } }

    it "hits redis up first" do
      expect(object.redis).to receive(:get).with("key").and_return('{"source":"redis"}')
      expect(request).not_to receive(:call)
      expect(object.cached_response("key", request)['source']).to eq('redis')
    end

    it "calls the lambda if redis returns nil" do
      expect(object.redis).to receive(:get).with("key").and_return(nil)
      expect(object.cached_response("key", request)['source']).to eq('lambda')
    end

    context "hitting the canvas API" do
      before do
        allow(object.redis).to receive(:get)
        stub_request(:get, "http://canvas/account.json").to_return(:status => 200, body: "{\"id\":3}", headers: {'Content-Type' => 'application/json'})
      end

      it "handles HTTParty::Responses properly" do
        request = double(call: HTTParty.get("http://canvas/account.json"))
        expect(object.cached_response("key", request)['id']).to eq(3)
      end

      it "handles arrays (paginated results) properly" do
        request = double(call: [HTTParty.get("http://canvas/account.json")])
        expect(object.cached_response("key", request).first['id']).to eq(3)
      end
    end
  end

  describe "redis_key" do
    specify { expect(object.redis_key(:section, 1)).to eq("abc123:section:1") }
  end
end
