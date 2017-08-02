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

InstructureRollcall.Views.Statuses ||= {}

class InstructureRollcall.Views.Statuses.DeskView extends InstructureRollcall.Views.Statuses.StatusView
  template: JST["backbone/templates/statuses/desk"]
  tagName: "div"

  events: _.extend(
    "click .classroom-modal-display" : "detailsModal",
    InstructureRollcall.Views.Statuses.StatusView.prototype.events)

  detailsModal: (event) ->
    event.preventDefault()
    @detailsView = new InstructureRollcall.Views.Statuses.DetailsView(model: @model, indexView: @indexView, statusView: this)
    $('#student-details').html(@detailsView.render().el)
    $("#student-details").dialog
      height: 350
      width: 550
      minWidth: 500
      modal: true

  setClass: ->
    InstructureRollcall.Views.Statuses.StatusView.prototype.setClass.call(this)
    @$el.addClass 'student-desk'

  toggleDraggable: (drag) =>
    if drag then @makeDraggable() else @makeUndraggable()

  makeDraggable: =>
    @disableStatus()
    @$el.draggable
      cursor: 'move'
      helper: 'clone'
      opacity: 0.5
      revert: 'false'
      containment: 'document'
      cursorAt:
        top: 8
        left: 80
      start: =>
        @$el.addClass 'student-dragged'
      stop: =>
        @$el.removeClass 'student-dragged'
 
  makeUndraggable: =>
    @enableStatus()
    @$el.draggable 'destroy'

  disableStatus: =>
    @$('a:first').removeClass("student-toggle").attr("title", "Click and drag to move this student around the seating chart")

  enableStatus: =>
    @$('a:first').addClass("student-toggle").attr("title", "Click to toggle this student's attendance")

  seated: => @$el.parent().hasClass("classroom-seat")

  coordinates: =>
    if @seated()
      seat = @$el.parent()
      row: seat.data('row'), col: seat.data('col')

  updateStatus: =>
    @model.set 'seated', @seated()
    if coords = @coordinates()
      @model.set 'row', coords.row
      @model.set 'col', coords.col
