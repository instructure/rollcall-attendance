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

describe CourseTardyWeight do
  describe "for" do
    let(:course_id) { 1 }
    let(:tool_consumer_instance_guid) { 'abc123' }

    subject { CourseTardyWeight.for(course_id, tool_consumer_instance_guid) }

    context "by default" do
      it { is_expected.to eq(0.8) }
    end

    context "with a custom tardy weight" do
      before { CourseConfig.create!(course_id: course_id, tardy_weight: 0.5, tool_consumer_instance_guid: tool_consumer_instance_guid) }
      it { is_expected.to eq(0.5) }
    end
  end
end
