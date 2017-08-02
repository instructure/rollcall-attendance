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

class InstructureRollcall.Models.Badge extends Backbone.Model
  paramRoot: 'badge'
  urlRoot: '/badges'

  defaults:
    account_id: null
    course_id: null
    icon: null
    name: null
    color: null

class InstructureRollcall.Collections.BadgesCollection extends Backbone.Collection
  model: InstructureRollcall.Models.Badge
  url: '/badges'

  fetchForCourse: (courseId) ->
    @fetch
      data: $.param
        course_id: courseId
