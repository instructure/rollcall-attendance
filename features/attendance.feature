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

Feature: Attendance

  Background:
    Given I am a teacher with 1 section and 2 students
    When I go to take attendance
    
  @javascript
  Scenario: Clicking a student's name toggles their presence
    Then the first student should be unmarked
    When I click the first student
    Then the first student should be present today
    When I click the first student
    Then the first student should be absent today
    When I click the first student again
    Then the first student should be late today
    When I click the first student again
    Then the first student should be unmarked

  @javascript
  Scenario: Mark/unmark all buttons
    When I click the mark all as present button
    Then all students should be present
    When I click the unmark all button
    Then all students should be unmarked

  @javascript
  Scenario: Sync stress test
    When I click the first student 13 times
    Then the first student should be present today
    When I click the first student again
    Then the first student should be absent today
    When I click the first student 9 times
    Then the first student should be late today
    When I click the first student 5 times
    Then the first student should be unmarked
