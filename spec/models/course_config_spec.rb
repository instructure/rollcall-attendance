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

describe CourseConfig do
  let(:course_id) { 1 }
  let(:tci_guid) { 'abc123' }
  subject(:config) {
    CourseConfig.new(course_id: course_id, tool_consumer_instance_guid: tci_guid)
  }

  describe "validations" do
    it { is_expected.to be_valid }

    it { is_expected.to allow_value(1).for(:tardy_weight) }
    it { is_expected.to allow_value(0).for(:tardy_weight) }
    it { is_expected.not_to allow_value(100).for(:tardy_weight) }
  end
end
