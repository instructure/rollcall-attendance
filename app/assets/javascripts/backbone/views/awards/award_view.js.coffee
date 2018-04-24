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

InstructureRollcall.Views.Awards ||= {}

class InstructureRollcall.Views.Awards.AwardView extends Backbone.View
  template : JST["backbone/templates/awards/award"]

  events:
    "click" : "toggle"

  initialize: ->
    @detailsView = @options.detailsView
    @model.bind 'sync', @detailsView.refreshAwardStats

  toggle: (event) =>
    event.preventDefault()
    
    @model.toggle()
    @setButtonState()

  setButtonState: ->
    @$el.toggleClass 'chosen-cat', @model.isAwarded()
    @$el.toggleClass 'chosen', @model.isAwarded()
    badgeName = _.escape(@model.get('badge').name)

    if @model.isAwarded()
      @$el.css("background", @$el.data("color")).attr("title", "Click to un-award this badge")
      @$el.attr("aria-label", "Click to remove #{badgeName} award")
    else
      @$el.css("background", '').attr("title", "Click to award this badge")
      @$el.attr("aria-label", "Click to award #{badgeName} badge")

  templateOptions: ->
    options = @model.toJSON()
    options.badge.name = _.escape(options.badge.name)
    options

  render: =>
    html = @template(@templateOptions())
    @el = $(html)
    @$el = @el
    @delegateEvents()
    @setButtonState()
    return this
