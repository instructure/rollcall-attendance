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

Feature: Students

  Background:
    Given I am a student in a course with 1 late day, 2 absent days, and 3 present days
    When I visit the tool as a student

  @javascript
  Scenario: Viewing attendance tallies
    Then I should see a total number of days for which attendance was taken
    And I should see the total number of individual statuses

  @javascript
  Scenario: Viewing current grade
    Then I should see my current grade

  @javascript
  Scenario: Viewing days with fewer than max possible points given
    Then I should see days marked late or absent
