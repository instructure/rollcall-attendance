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

Feature: Require launch

  Scenario: Trying to access the root URL before having launched the app
    When I go to the root url without having launched the app
    Then I should be told I need to launch the app

  Scenario: Trying to access a course
    When I go to a course without having launched the app
    Then I should be told I need to launch the app

  Scenario: Trying to access an account
    When I go to an account without having launched the app
    Then I should be told I need to launch the app
