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

Feature: Sections

  Scenario: When I have one section
    Given I am a teacher with 1 section and 2 students
    When I go to take attendance
    Then I should be on my first section and it should be the active tab
    
  Scenario: When I have multiple sections
    Given I am a teacher with 2 sections and 2 students in each
    When I go to take attendance
    Then I should see a list of my sections
    When I click the first section
    Then I should be on my first section and it should be the active tab
