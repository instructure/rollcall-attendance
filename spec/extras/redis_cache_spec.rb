#
# Copyright (C) 2021 - present Instructure, Inc.
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

describe RedisCache do
  let(:object) { Object.new }
  let(:key) {"abc123:section:1"}
  let(:request) { lambda { { 'source' => 'lambda' } } }
  let(:response) { { 'hash' => 'value' } }
  before {
    object.extend(RedisCache)
  }

  describe "Build Redis key" do
    it { expect(object.redis_key("abc123", :section, 1)).to eq(key) }
  end

  describe "Value gets saved in cache" do
    after do
      object.redis.del key
    end

    it "sets the value in redis" do
      object.cache_value(key, 5, response.to_json)
      expect(object.redis.get(key)).to eq(response.to_json)
    end
  end

  describe "Checks if value is cached" do
    before { object.redis.setex(key, 5, response.to_json) }

    after { object.redis.del(key) }

    it "returns true when key is found in redis" do
      expect(object.is_cached?(key)).to eq(true)
    end

    it "returns false when key not found in redis" do
      expect(object.is_cached?("key_not_saved")).to eq(false)
    end
  end

  describe "Value is fetched from redis" do
    before(:each) do
      object.redis.setex(key, 5, response.to_json)
    end
    after(:each) do
      object.redis.del key
    end

    it "redis get method is called with key" do
      expect(object.redis).to receive(:get).with(key)
      object.cached_value(key)
    end

    it "returns value" do
      expect(object.cached_value(key)).to eq(response.to_json)
    end
  end

  describe "Fetch from API" do
    after(:each) do
      object.redis.del key
    end

    it "calls on api request" do
      expect(request).to receive(:call)
      object.fetch_from_api(key, request)
    end

    it "returns the correct value" do
      request_response = { 'source' => 'lambda' }.to_json
      expect(object.fetch_from_api(key, request)).to eq(request_response)
    end

    it "sets response on redis" do
      expect(object).to receive(:cache_value)
      object.fetch_from_api(key, request)
    end

    context "when request call returns nill" do
      before do
        allow(request).to receive(:call).and_return(nil)
      end

      after(:each) do
        object.redis.del key
      end

      it "returns empty json if call returns blank" do
        expect(object.fetch_from_api(key, request)).to eq("{}")
      end

      it "does not save in redis" do
        expect(object).not_to receive(:cache_value)
        object.fetch_from_api(key, request)
      end
    end
  end

  describe "Get cached response" do
    after(:each) { object.redis.del key }
    let(:request_response) { { 'source' => 'lambda' }.to_json }

    context "when key is found in redis" do
      it "fetches api response from cache" do
        object.redis.setex(key, 5, response.to_json)
        expect(object).to receive(:cached_value).with(key).and_return(response.to_json)
        object.cached_response(key, request)
      end
    end

    context "when response is not cached" do
      it "fetches response form API" do
        expect(object).to receive(:fetch_from_api).with(key,request).and_return(request_response)
        object.cached_response(key, request)
      end

      it "redis returns nil" do
        expect(object).to receive(:cached_value).with(key).and_return(nil)
        object.cached_response(key, request)
      end
    end
  end
end
