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

Feature: Badges

  Background:
    Given I am a teacher with 1 section and 2 students

  @javascript
  Scenario: Creating a new badge and using it immediately
    When I go to take attendance
    When I click to see the first student's details
    And I click the button to add a new badge
    Then I should see the new badge form
    When I fill out the form to create a participation badge
    And I save the badge
    Then there should be a participation badge for my course
    When I click my new participation badge
    Then the student should have a participation badge
    When I click my new participation badge again
    Then the student should not have a participation badge
    
  @javascript
  Scenario: Using an existing badge and watching the stats update
    Given my course has a good citizen badge
    When I go to take attendance
    And I click to see the first student's details
    And I click the good citizen badge
    Then my student should have a good citizen badge
    And the stats should show one good citizen point
    When I click the good citizen badge again
    Then the stats should show zero good citizen points

  @javascript
  Scenario: Editing a badge
    Given my course has a good citizen badge
    When I go to take attendance
    And I click to see the first student's details
    And I click the edit badges button
    And I click the button to edit the good citizen badge
    And I change the name of the badge to bad citizen
    When I save the badge
    Then there should be a bad citizen badge for my course
    And there should not be a good citizen badge for my course
    And I should see the bad citizen badge in the list of badges
    And I should see the bad citizen badge in the student details
    And I should see the bad citizen badge in the list of stats

  @javascript
  Scenario: Deleting a badge
    Given my course has a good citizen badge
    When I go to take attendance
    And I click to see the first student's details
    And I click the edit badges button
    And I click the button to delete the good citizen badge
    Then there should not be a good citizen badge for my course
