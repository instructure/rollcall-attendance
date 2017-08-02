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

When /^I go to the root url without having launched the app$/ do
  ApplicationController.any_instance.stub(:canvas_url) { nil }  
  visit '/'
end

When /^I go to an account without having launched the app$/ do
  AccountsController.any_instance.stub(:canvas_url) { nil }
  visit '/accounts/1'
end

When /^I go to a course without having launched the app$/ do
  SectionsController.any_instance.stub(:canvas_url) { nil }
  visit '/courses/1'
end

Then /^I should be told I need to launch the app$/ do
  page.should have_content "Please launch this tool from Canvas and then try again."
end
