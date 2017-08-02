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

Feature: Details view

  Background:
    Given I am a teacher with 1 section and 2 students
    And the first student has an attendance record
    When I go to take attendance

  @javascript
  Scenario: Clicking a student's details pops up their information
    When I click to see the first student's details
    Then I should see their name in the details pane
    And I should see their latest statistics

  @javascript
  Scenario: Changing a student's status through the details view
    When I click to see the first student's details
    And I toggle them to present in the list view
    Then the details view should show the student as present
    When I wait for the sync
    Then I should see their latest statistics
    When I toggle them to absent in the details
    Then the list view should show the student as absent
    When I wait for the sync
    Then I should see their latest statistics

  @javascript
  Scenario: Navigating through time with the details view open
    When I click to see the first student's details
    And I toggle them to present in the list view
    And I wait for the sync
    And I click the button for the previous day
    Then the student should be unmarked in the list view
    And the student should be unmarked in the details view
    When I click the button for the next day
    Then the student should be present in the list view
    And the student should be present in the details view
