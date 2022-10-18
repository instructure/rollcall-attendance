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

When /^I click the class tab$/ do
  find("#show-class a").click
  wait_for_sync
end

When /^I click the list tab$/ do
  find("#show-list a").click
end

Then /^the list view should(?: still)? be active$/ do
  wait_for_sync
  page.should have_selector "#list-view-container"
  page.should have_selector "#show-list.active-toggle"
end

Then /^the class view should(?: still)? be active$/ do
  page.should have_selector "#class-view-container"
  page.should have_selector "#show-class.active-toggle"
end

When /^I click the first desk(?: again)?$/ do
  first_desk.find('.student-toggle').click
end

Then /^the student in the first desk should be (\w+) (today|yesterday)$/ do |attendance, class_date|
  class_date = case class_date
    when 'today'
      Date.today
    when 'yesterday'
      Date.yesterday
    end

  first_desk['class'].should match attendance

  expect do
    first_student_status(class_date).try(:attendance) == attendance
  end.to become_true
end

Then /^the student in the first desk should be unmarked$/ do
  first_desk['class'].should match 'unmarked'
end

Then /^I should be on the edit seating chart sub\-tab$/ do
  page.should have_selector "#move-students-toggle.active-toggle"
  page.should have_selector ".unassigned-list"
  page.should have_selector ".attendance-selector", visible: false
end

Given /^I have a seating chart for my course already$/ do
  create(:seating_chart, course_id: 1, section_id: 1, class_date: Date.yesterday, tool_consumer_instance_guid: 'abc123', assignments: {
    '1' => { 'row' => 1, 'col' => 1 },
    '2' => { 'row' => 2, 'col' => 2 }
    })
end

Then /^I should be on the take attendance sub\-tab$/ do
  page.should have_selector "#take-attendance-toggle.active-toggle"
  page.should have_selector ".attendance-selector", visible: true
end

When /^I drag a student down from the unassigned list to the grid$/ do
  student = find(".ui-draggable", text: 'student1')
  chair = find("#seat-3-3")
  student.drag_to(chair)
end

Then /^the seating chart should be posted to the server$/ do
  expect do
    SeatingChart.count == 1
  end.to become_true
end

Then /^my student should be in the same place that I dragged them$/ do
  page.should have_selector("#seat-3-3", text:'student1')
end

When /^I click the take attendance sub\-tab$/ do
  click_link "take-attendance-toggle"
end

Then /^only that student should be present today$/ do
  Status.count.should == 1
  Status.first.attendance.should == 'present'
end

Then /^I should have two seating charts$/ do
  expect do
    SeatingChart.count == 2
  end.to become_true
end

When /^I click the first student's name$/ do #'
  find('.classroom-modal-toggle', text: "student1").click
end

Then /^I should see their details in a modal dialog$/ do
  page.should have_selector('.ui-dialog', text:"student1")
end

When /^I close the details dialog$/ do
  click_button 'Close'
end

When /^I drag both students back to the unassigned list$/ do
  unassigned = find(".unassigned-list")
  wait_for_sync

  all(".student-desk").each do |desk|
    desk.drag_to unassigned
  end
end

Then /^they should be in alphabetical order$/ do
  unassigned = all(".unassigned-list .student-desk")
  unassigned.first.text.should == 'student1@12spokes.com'
  unassigned.last.text.should == 'student3@12spokes.com'
end

Then /^I should see instructions on how to create my seating chart$/ do
  page.should have_content "To create your seating chart"
end

When /^I click the edit seating chart sub\-tab$/ do
  click_link "Edit seating chart"
end

def first_desk
  find('.student-desk', text: "student1")
end
