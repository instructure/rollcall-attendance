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

class InstructureRollcall.Models.Status extends Backbone.Model
  paramRoot: 'status'

  defaults:
    student: null
    student_id: null
    section_id: null
    attendance: null
    class_date: null

  initialize: => @initializeToggleSync(this)

  delete: =>
    # TODO: Inherit from ToggleSync mixin and pull in the stats update some other way
    Backbone.sync 'delete', this, success: (response) =>
      @set 'stats', response.stats
      @trigger 'sync'
    , error: (model, response, options) =>
      @showError(this, response, options)

    @set(id: null)

  toggledOff: -> @isUnmarked()

  markAsAbsent: ->
    @set(attendance: 'absent')
    @queueSave()

  markAsPresent: ->
    @set(attendance: 'present')
    @queueSave()

  markAsLate: ->
    @set(attendance: 'late')
    @queueSave()

  unmark: ->
    @set(attendance: null)
    @queueSave()
    
  isLate: ->
    @get('attendance') == 'late'

  isAbsent: ->
    @get('attendance') == 'absent'

  isPresent: ->
    @get('attendance') == 'present'

  isUnmarked: ->
    !@get('attendance')?

  attendance: ->
    if @isUnmarked()
      'unmarked'
    else
      @get('attendance')

  togglePresence: ->
    if @isPresent()
      @markAsAbsent()
    else if @isAbsent()
      @markAsLate()
    else if @isLate()
      @unmark()
    else if @isUnmarked()
      @markAsPresent()

  firstName: -> @get('student').name.split(' ')[0]

_.extend InstructureRollcall.Models.Status.prototype, InstructureRollcall.Mixins.ToggleSync.prototype, { delete: InstructureRollcall.Models.Status.prototype.delete }

class InstructureRollcall.Collections.StatusesCollection extends Backbone.Collection
  model: InstructureRollcall.Models.Status
  url: '/statuses'
  comparator: (status)->
    status.get('student')?['sortable_name']
