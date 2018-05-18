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

class InstructureRollcall.Mixins.ToggleSync
  initializeToggleSync: (@model) =>
    @model.bind 'error sync', @commitOrUnlock

  queueSave: =>
    @queuedParams = @model.toJSON()
    delete @queuedParams['id']
    @commit() unless @isLocked()

  isLocked: => @locked == true

  lock: => @locked = true

  unlock: => @locked = false

  applyQueue: =>
    @model.set(@queuedParams)
    @queuedParams = null

  commitOrUnlock: => if @queuedParams? then @commit() else @unlock()

  showError: (model, resp, options) =>
    $('#ajax-error').show()
    model.trigger('error', model, resp, options)
    setTimeout =>
      $('#ajax-error').fadeOut()
      @errorTimeout = null
    , 5000

  commit: =>
    @lock()
    @applyQueue()

    unless @model.toggledOff()
      @model.save(null, error: @showError)
    else if @model.get('id')
      @delete()
    else
      # already deleted
      @model.trigger 'sync'

  delete: =>
    Backbone.sync 'delete', @model, success: (response) =>
      @model.trigger 'sync'
    , error: =>
      @model.trigger 'error'

    @model.set(id: null)
