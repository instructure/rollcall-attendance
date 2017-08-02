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

class InstructureRollcall.Models.Award extends Backbone.Model
  paramRoot: 'award'

  defaults:
    course_id: null
    student_id: null
    badge_id: null
    class_date: null

  initialize: =>
    @initializeToggleSync(this)
    @updateAwarded()
    @bind 'sync', @updateAwarded

  updateAwarded: =>
    @awarded = !@isNew()

  toggledOff: => !@isAwarded()

  isAwarded: -> @awarded

  toggleOn: ->
    @awarded = true
    @queueSave()

  toggleOff: ->
    @awarded = false
    @queueSave()

  toggle: -> if @isAwarded() then @toggleOff() else @toggleOn()
    
_.extend InstructureRollcall.Models.Award.prototype, InstructureRollcall.Mixins.ToggleSync.prototype

class InstructureRollcall.Collections.AwardsCollection extends Backbone.Collection
  model: InstructureRollcall.Models.Award
  url: '/awards'

  fetchForStudent: (courseId, studentId, classDate) ->
    @fetch
      data: $.param
        course_id: courseId
        student_id: studentId
        class_date: classDate

  statsForStudent: (courseId, studentId, callback) ->
    $.get "/awards/stats.json?course_id=#{courseId}&student_id=#{studentId}", (response) -> callback(response)
