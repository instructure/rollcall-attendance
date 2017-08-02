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

When /^I click to see the first student's details$/ do #'
  first_student.find(".student-detail-toggle-link").click
  wait_for_sync
end

Then /^I should see their name in the details pane$/ do
  page.find('.student-detail-display').should have_content 'student1@12spokes.com'
end

Given /^the first student has an attendance record$/ do
  {
    8.days.ago => 'present',
    7.days.ago => 'present',
    6.days.ago => 'present',
    5.days.ago => 'late',
    4.days.ago => 'late',
    3.days.ago => 'absent'
  }.each do |class_date, attendance|
    create(:status, student_id: 1, section_id: 1, class_date: class_date, attendance: attendance, course_id: 1, tool_consumer_instance_guid: 'abc123')
  end
end

Then /^I should see their latest statistics$/ do
  stats = StudentCourseStats.new(1, 1, 1, 'abc123')
  details_view.should have_content "Present: #{stats.presences}"
  details_view.should have_content "Late: #{stats.tardies}"
  details_view.should have_content "Absent: #{stats.absences}"
  details_view.should have_content stats.grade
end

When /^I toggle them to present in the list view$/ do
  first_student.find('a.student-toggle').click
end

Then /^the details view should show the student as present$/ do
  details_view.should have_content "student1@12spokes.com is present"
  details_view.should have_css ".toggle-present.active-toggle"
end

When /^I toggle them to absent in the details$/ do
  details_view.find('.toggle-absent').click
end

Then /^the list view should show the student as absent$/ do
  first_student['class'].should match 'absent'
end

Then /^the student should be unmarked in the list view$/ do
  first_student['class'].should match 'unmarked'
end

Then /^the student should be unmarked in the details view$/ do
  details_view.should have_css '.toggle-unmarked.active-toggle'
end

Then /^the student should be present in the list view$/ do
  first_student['class'].should match 'present'
end

Then /^the student should be present in the details view$/ do
  details_view.should have_css '.toggle-present.active-toggle'
end

def details_view
  page.find('.student-detail-display')
end
