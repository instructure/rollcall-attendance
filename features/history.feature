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

Feature: Historical attendance

  Background:
    Given I am a teacher with 1 section and 2 students

  @javascript
  Scenario: Going back to a previous day, changing the attendance, then navigating forward and backward
    When I go to take attendance
    Then all students should be unmarked
    When I click the button for the previous day
    And I click the mark all as present button
    Then all students should be present
    When I click the button for the next day
    Then all students should be unmarked
    When I click the button for the previous day
    Then all students should be present
