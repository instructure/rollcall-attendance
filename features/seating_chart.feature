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

Feature: Seating chart

  Background:
    Given I am a teacher with 1 section and 2 students

  @javascript
  Scenario: Clicking between list and class view and saving the view preference
    When I go to take attendance
    Then the list view should be active
    When I click the class tab
    Then the class view should be active
    When I go to take attendance again
    Then the class view should still be active
    When I click the list tab
    Then the list view should be active
    When I go to take attendance again
    Then the list view should still be active

  @javascript
  Scenario: Toggling attendance on the class view
    Given I have a seating chart for my course already
    When I go to take attendance
    And I click the class tab
    When I click the first desk
    Then the student in the first desk should be present today
    When I click the first desk again
    Then the student in the first desk should be absent today
    When I click the first desk again
    Then the student in the first desk should be late today
    When I click the first desk again
    Then the student in the first desk should be unmarked

  @javascript
  Scenario: Going to the class view when there is no seating chart
    When I go to take attendance
    And I click the class tab
    Then I should be on the edit seating chart sub-tab

  @javascript
  Scenario: Going to the class view when there is a seating chart for that day
    Given I have a seating chart for my course already
    When I go to take attendance
    And I click the class tab
    Then I should be on the take attendance sub-tab

  @javascript
  Scenario: Dragging a student from the unassigned list to the grid
    When I go to take attendance
    And I click the class tab
    When I drag a student down from the unassigned list to the grid
    Then the seating chart should be posted to the server
    When I go to take attendance again
    Then I should be on the take attendance sub-tab
    And my student should be in the same place that I dragged them

  @javascript
  Scenario: Dragging a student from the grid to the unassigned list
    Given I have a seating chart for my course already
    When I go to take attendance
    And I click the class tab
    And I click the edit seating chart sub-tab
    And I drag both students back to the unassigned list
    Then they should be in alphabetical order
    And I should see instructions on how to create my seating chart

  @javascript
  Scenario: Clicking mark all present only marks students on the seating chart
    When I go to take attendance
    And I click the class tab
    When I drag a student down from the unassigned list to the grid
    And I click the take attendance sub-tab
    And I click the mark all as present button
    Then only that student should be present today

  @javascript
  Scenario: Marking a student and switching between views
    Given I have a seating chart for my course already
    When I go to take attendance
    And I click the first student
    When I click the class tab
    Then the student in the first desk should be present today
    When I click the first desk
    Then the student in the first desk should be absent today
    When I click the list tab
    Then the first student should be absent today

  @javascript
  Scenario: Historical seating charts
    When I go to take attendance
    And I click the class tab
    When I drag a student down from the unassigned list to the grid
    And I click the button for the previous day
    When I drag a student down from the unassigned list to the grid
    Then I should have two seating charts

  @javascript
  Scenario: Viewing the details view modal dialog
    Given I have a seating chart for my course already
    When I go to take attendance
    And I click the class tab
    When I click the first desk
    And I click the first student's name
    Then I should see their details in a modal dialog
    Then the details view should show the student as present
    When I toggle them to absent in the details
    And I close the details dialog
    Then the student in the first desk should be absent today
