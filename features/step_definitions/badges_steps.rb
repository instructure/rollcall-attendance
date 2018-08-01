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

When /^I click the button to add a new badge$/ do
  click_link "Add badge"
end

Then /^I should see the new badge form$/ do
  page.should have_content "What would you like to call this badge?"
end

When /^I fill out the form to create a participation badge$/ do
  fill_in "name", with: "Participation"
  find('div[title=Approve]').click
  find('div[title=green]').click
end

When /^I save the badge$/ do
  click_link "Save badge"
  wait_for_sync
end

Then /^there should be a participation badge for my course$/ do
  expect do
    Badge.where(name: "Participation", course_id: 1, tool_consumer_instance_guid: 'abc123').count == 1
  end.to become_true
end

When /^I click my new participation badge(?: again)?$/ do
  click_link "Participation"
end

Then /^the student should have a participation badge$/ do
  wait_for_sync
  find('a', text: "PARTICIPATION")['class'].should match 'chosen'
  Award.where(student_id: 1, tool_consumer_instance_guid: 'abc123').count.should == 1
end

Then /^the student should not have a participation badge$/ do
  wait_for_sync
  find('a', text: "PARTICIPATION")['class'].should_not match 'chosen'
  Award.where(student_id: 1, tool_consumer_instance_guid: 'abc123').count.should == 0
end

Given /^my course has a good citizen badge$/ do
  @badge = FactoryBot.create(:badge, course_id: 1, name: "Good citizen", icon: "+", color: "blue", tool_consumer_instance_guid: 'abc123')
end

When /^I click the good citizen badge(?: again)?$/ do
  click_link "Good citizen"
end

Then /^my student should have a good citizen badge$/ do
  wait_for_sync
  Award.where(student_id: 1, tool_consumer_instance_guid: 'abc123').first.badge.should == @badge
end

Then /^the stats should show one good citizen point$/ do
  page.should have_content "Good citizen: 1"
end

Then /^the stats should show zero good citizen points$/ do
  page.should have_content "Good citizen: 0"
end

When /^I click the edit badges button$/ do
  # capybara has a weird bug where it can't click on a link that has an icon
  # class on it because the :before pseudo-selector messes it up
  execute_script "$('.manage-badges').removeClass('icon icon-edit');"
  click_link "Manage badges"
end

When /^I click the button to edit the good citizen badge$/ do
  find(".edit-badge").click
end

When /^I change the name of the badge to bad citizen$/ do
  fill_in "name", with: "Bad citizen"
end

Then /^there should be a bad citizen badge for my course$/ do
  expect do
    Badge.where(name: "Bad citizen", course_id: 1, tool_consumer_instance_guid: 'abc123').count == 1
  end.to become_true
end

Then /^there should not be a good citizen badge for my course$/ do
  expect do
    Badge.where(name: "Good citizen", course_id: 1, tool_consumer_instance_guid: 'abc123').count == 0
  end.to become_true
  wait_for_sync
  page.should_not have_content "Good citizen"
end

Then /^I should see the bad citizen badge in the list of badges$/ do
  find('.manage-badge-list').should have_content 'BAD CITIZEN'
end

Then /^I should see the bad citizen badge in the student details$/ do
  find('.badge-list').should have_content 'BAD CITIZEN'
end

Then /^I should see the bad citizen badge in the list of stats$/ do
  find('.badge-stats').should have_content 'Bad citizen'
end

When /^I click the button to delete the good citizen badge$/ do
  accept_confirm do
    find(".delete-badge").click
  end
  wait_for_sync
end
