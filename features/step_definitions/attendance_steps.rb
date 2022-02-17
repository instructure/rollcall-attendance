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

When /^I click the first student(?: again)?$/ do
  first_student.find('a.student-toggle').click and wait_for_sync
end

When /^I click the first student (\d+) times$/ do |count|
  count.to_i.times { first_student.find('a.student-toggle').click }
  wait_for_sync
end

Then /^the first student should be unmarked$/ do
  first_student['class'].should match 'unmarked'
end

Then /^the first student should be (\w+) (today|yesterday)$/ do |attendance, class_date|
  wait_for_sync
  class_date = case class_date
    when 'today'
      Date.today
    when 'yesterday'
      Date.yesterday
    end

  first_student['class'].should match attendance
  first_student_status(class_date).attendance.should == attendance
end

Then /^all students should be unmarked$/ do
  all('#student-list li').each do |el|
    el['class'].should match 'unmarked'
  end
end

Then /^there should be no status records in the database$/ do
  Status.count.should == 0
end

Then /^all students should be present$/ do
  wait_for_sync

  all('#student-list li').each do |el|
    el['class'].should match 'present'
  end

  Status.where(attendance: 'present', tool_consumer_instance_guid: 'abc123').count.should == Status.count
end

When /^I click the mark all as present button$/ do
  click_link 'mark-all-present' and wait_for_sync
end

When /^I click the unmark all button$/ do
  click_link 'unmark-all' and wait_for_sync
end
