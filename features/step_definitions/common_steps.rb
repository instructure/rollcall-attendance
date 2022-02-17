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

Then /^show me the page$/ do
  save_and_open_page
end

When /^I wait for the sync$/ do
  wait_for_sync
end

When /^I wait a second$/ do
  sleep 1.5
end

def first_student
  find('#student-list li', match: :first)
end

def first_student_status(class_date)
  Status.where(student_id: 1, class_date: class_date, tool_consumer_instance_guid: 'abc123').first
end

def wait_for_sync(duration = 0.1)
  sleep duration
end
