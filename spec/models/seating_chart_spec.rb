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

describe SeatingChart do
  subject(:seating_chart) { SeatingChart.new }

  describe "validations" do
    specify { expect(build_stubbed(:seating_chart)).to be_valid }
    it { is_expected.to validate_presence_of :course_id }
    it { is_expected.to validate_presence_of :section_id }
    it { is_expected.to validate_presence_of :class_date }
  end

  describe "latest" do
    it "returns the latest seating chart for the given section as of a certain date" do
      seatingChart = create(
        :seating_chart,
        section_id: 1,
        class_date: 1.week.ago,
        tool_consumer_instance_guid: "abc123",
        course_id: 1
      )
      expect(SeatingChart.latest(3.days.ago, 1, "abc123", 1)).to eq(seatingChart)
    end
  end
end
