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

describe Pagination do
  let(:object) { Object.new }
  before { object.extend(Pagination) }

  before :each do
    object.class_eval do
      attr_accessor :params
    end
    object.params = ActionController::Parameters.new({})
  end

  describe '#pagination_params' do
    it 'returns a default set of params' do
      expect(object.pagination_params).to eql({ 'page' => 1, 'per_page' => 50 })
    end

    it 'adjusts to a lower bound for page' do
      object.params = ActionController::Parameters.new({ 'page' => -100 })
      expect(object.pagination_params).to eql({ 'page' => 1, 'per_page' => 50 })
    end

    it 'adjusts to a lower bound for per_page' do
      object.params = ActionController::Parameters.new({ 'per_page' => -100 })
      expect(object.pagination_params).to eql({ 'page' => 1, 'per_page' => 50 })
    end

    it 'adjusts to an upper bound for per_page' do
      object.params = ActionController::Parameters.new({ 'per_page' => 100 })
      expect(object.pagination_params).to eql({ 'page' => 1, 'per_page' => 50 })
    end

    it 'if no params are out of bounds, use user supplied params' do
      object.params = ActionController::Parameters.new({ 'page' => 5, 'per_page' => 24 })
      expect(object.pagination_params).to eql({ 'page' => 5, 'per_page' => 24 })
    end
  end

  describe '#collection_json' do
    require 'will_paginate/array'
    let(:test_array) { [0] * 100 }

    it 'returns collection with metadata' do
      collection = object.collection_json(test_array.paginate)
      expected = {
        data: [0] * 30,
        meta: {
          total_pages: 4,
          current_page: 1,
          per_page: 30,
          total_entries: 100
        }
      }
      expect(collection).to eq expected
    end

    it 'adjusts based on input params' do
      collection = object.collection_json(test_array.paginate(page: 3, per_page: 12))
      expected = {
        data: [0] * 12,
        meta: {
          total_pages: 9,
          current_page: 3,
          per_page: 12,
          total_entries: 100
        }
      }
      expect(collection).to eq expected
    end
  end
end
