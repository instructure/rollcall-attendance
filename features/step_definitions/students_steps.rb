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

Given /^I am a student in a course(?: with)(.*)$/ do |statuses|
  allow_any_instance_of(ApplicationController).to receive(:student_launch?).and_return(true)
  stub_request(:get, "http://test.canvas/api/v1/courses/1/assignments/2/submissions/2")
    .with(headers: { 'Authorization' => 'Bearer' })
    .to_return(status: 200, body: JSON.generate({ grade: 'C+' }), headers: { 'Content-Type' => 'application/json' })

  stub_request(:get, "http://test.canvas/api/v1/courses/1/assignments?per_page=50")
    .with(:headers => {'Authorization'=>'Bearer'})
    .to_return(:status => 200, :body => '[{"id":2,"name":"Roll Call Attendance"}]', headers: {'Content-Type' => 'application/json'})

  statuses.scan(/(\d+) (\w+) days?/).each do |days, state|
    days.to_i.times.each do |day|
      create_status(1, 2, state, Status.count.days.ago)
    end
  end
end

When /^I visit the tool as a student$/ do
  visit '/courses/1/students/2'
  wait_for_sync
end

When /^I scroll to the bottom of the page$/ do
  page.execute_script "window.scrollBy(0, 10000)"
  wait_for_sync 1
end

Then /^I should see a total number of days for which attendance was taken$/ do
  find('.student-chart-title').should have_content "6\nDays Total"
end

Then /^I should see the total number of individual statuses$/ do
  totals = find('.attendance-totals')
  totals.should have_content '1 Late Day'
  totals.should have_content '2 Absent Days'
  totals.should have_content '3 Present Days'
end

Then /^I should see my current grade$/ do
  find('.submission-grade-container').should have_content "C+\nCurrent Score"
end

Then /^I should see days marked late or absent$/ do
  find('.student-table').should have_content "#{Time.now.utc.strftime('%b %-d %A')} Late 80%"
end

Then /^I should see (\d+) statuses$/ do |number_of_statuses|
  find('.student-table').all('tbody tr').length.should eql number_of_statuses.to_i
end

def create_status(course_id, student_id, attendance_state, class_date)
  Status.create! course_id: course_id, student_id: student_id, attendance: attendance_state, class_date: class_date,
    section_id: 1, account_id: 1, tool_consumer_instance_guid: 'abc123', teacher_id: 1
end
