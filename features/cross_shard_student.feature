#
# Copyright (C) 2018 - present Instructure, Inc.
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

Feature: Cross-shard students

  Background:
    Given I am a teacher with 1 section and 2 cross-shard students
    When I go to take attendance

  @javascript
  Scenario: Toggling the statuses of a cross-shard student
    Then the first student should be unmarked
    When I click the first student
    Then the first student should be present today
    When I click the first student
    Then the first student should be absent today
    When I click the first student again
    Then the first student should be late today
    When I click the first student again
    Then the first student should be unmarked
