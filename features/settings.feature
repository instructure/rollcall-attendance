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

Feature: Settings

  Background:
    Given I am a teacher with 1 section and 2 students
    When I go to take attendance

  @javascript
  Scenario: Changing the tardy weight
    When I click the settings cog at the top
    And I click the Roll Call Settings link
    Then I should see the slider for the tardy weight
    And I should see the tardy weight is 80 percent
    When I change the tardy weight to 50 percent
    And I close the settings dialog
    And I go to take attendance
    When I click the settings cog at the top
    And I click the Roll Call Settings link
    Then I should see the tardy weight is 50 percent
