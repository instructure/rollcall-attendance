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

InstructureRollcall.Views.Badges ||= {}

class InstructureRollcall.Views.Badges.BadgeView extends Backbone.View
  template : JST["backbone/templates/badges/badge"]
  tagName: 'li'

  events:
    "click .delete-badge" : "delete"
    "click .edit-badge" : "edit"

  edit: ->
    new InstructureRollcall.Views.Badges.EditView(model: @model)

  delete: =>
    if confirm "Are you sure you want to delete the #{@model.get 'name'} badge?"
      @model.destroy(wait: true)
      @$el.remove()
      $(".ui-dialog").focus()

  render : ->
    @$el.html(@template(@model.toJSON()))
    return this
