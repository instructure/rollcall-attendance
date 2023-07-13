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

When /^I click the settings cog at the top$/ do
  page.execute_script "$('.rollcall-dropdown-list').removeClass('visuallyhidden').addClass('active')"
end

When /^I click the Roll Call Settings link$/ do
  click_link "Roll Call Settings"
end

Then /^I should see the slider for the tardy weight$/ do
  page.should have_css "#lateness-percentage-slider"
end

When /^I change the tardy weight to (\d+) percent$/ do |percent|
  page.execute_script "$('#lateness-percentage-slider').slider('value', '#{percent}')"
end

Then /^I should see the tardy weight is (\d+) percent$/ do |percent|
  page.should have_css("#lateness-percentage", text:"#{percent}%")
end

When /^I close the settings dialog$/ do
  find('.ui-dialog-titlebar-close').click
end

Then /^I should see the omit from final grade checkbox$/ do
  page.should have_field("omit-checkbox", type: 'checkbox')
end

When /^I should see the omit from final grade checkbox is unchecked$/ do
  !page.find_by_id('omit-checkbox')['checked']
end

When /^I click on the omit from final grade checkbox$/ do
  check 'Do not count attendance toward final grade'
end

Then /^I should see the omit from final grade checkbox is checked$/ do
  page.find_by_id('omit-checkbox')['checked']
end
