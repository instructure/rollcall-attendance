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

FactoryGirl.define do
  factory :award do
    student_id 1
    teacher_id 5
    badge_id 2
    course_id 3
    class_date { Time.now.utc.to_date }
    tool_consumer_instance_guid "abc123"
  end

  factory :badge do
    name 'Participation'
    course_id 1
    icon '+'
    color 'blue'
    tool_consumer_instance_guid "abc123"
  end

  factory :seating_chart do
    course_id 1
    section_id 2
    class_date { Time.now.utc.to_date }
    tool_consumer_instance_guid "abc123"
  end

  factory :status do
    student_id 1
    section_id 1
    attendance 'present'
    class_date { Time.now.utc.to_date }
    course_id 1
    account_id 3
    teacher_id 5
    tool_consumer_instance_guid "abc123"
  end

  factory :cached_account do
    sequence(:account_id) { |n| n + 1000 }
    tool_consumer_instance_guid "abc123"
  end

  factory :account_association do
    cached_account {}
    descendant {}
  end
end
