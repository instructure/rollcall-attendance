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

class InstructureRollcall.Views.Statuses.ClassView extends Backbone.View
  template: JST["backbone/templates/statuses/class"]

  events:
    "click #take-attendance-toggle" : "switchToAttendanceMode"
    "click #move-students-toggle" : "switchToEditMode"
    'click #mark-all-present': 'markAllSeatedPresent'
    'click #unmark-all': 'unmarkAllSeated'

  markAllSeatedPresent: (event) ->
    event.preventDefault()

    _.each @desks, (desk) ->
      desk.model.markAsPresent() if desk.seated()

  unmarkAllSeated: (event) ->
    event.preventDefault()

    _.each @desks, (desk) ->
      desk.model.unmark() if desk.seated()

  initialize: ->
    @indexView = @options.indexView
    @bind 'student-dragged', @studentDragged

  switchToAttendanceMode: (event) =>
    event.preventDefault() if event?
    @$("#take-attendance-toggle").addClass("active-toggle")
    @$("#move-students-toggle").removeClass("active-toggle")
    @toggleDesks(draggable = false)
    @$("div.grid-container").removeClass("list-open")
    @showMarkAllButtons()
    @hideInstructions()

  switchToEditMode: (event) =>
    event.preventDefault() if event?
    @$("#take-attendance-toggle").removeClass("active-toggle")
    @$("#move-students-toggle").addClass("active-toggle")
    @toggleDesks(draggable = true)
    @$("div.grid-container").addClass("list-open")
    @hideMarkAllButtons()
    @toggleInstructions()

  toggleDesks: (draggable) =>
    _.each @desks, (desk) => desk.toggleDraggable(draggable)

  saveSeatingChart: ->
    chart = new InstructureRollcall.Models.SeatingChart
      course_id: @indexView.courseId
      section_id: @indexView.sectionId
      class_date: @indexView.classDate.toString("yyyy-MM-dd")

    assignments = {}
    _.each @desks, (desk) =>
      desk.updateStatus()

      if desk.seated()
        assignments[desk.model.get('student_id')] = desk.coordinates()

    chart.set('assignments', assignments)
    chart.save()

  anySeatedStudents: =>
    _.any @desks, (desk) -> desk.seated()

  anyUnassignedStudents: =>
    _.any @desks, (desk) -> !desk.seated()

  addAll: =>
    @desks = []
    @$(".student-desk").remove()
    @indexView.statuses.each(@addOne)

    if @anySeatedStudents()
      @switchToAttendanceMode()
    else
      @switchToEditMode()

  addOne: (status) =>
    desk = new InstructureRollcall.Views.Statuses.DeskView({model : status, indexView: @indexView})
    @desks.push desk
    html = desk.render().el

    if status.get('seated')
      @seatStudent(html, status)
    else
      @unseatStudent(html)

  unseatStudent: (desk) =>
    added = false

    @$(".unassigned-list .student-desk").each (index, otherDesk) =>
      if $(otherDesk).text().toUpperCase() > $(desk).text().toUpperCase()
        $(desk).insertBefore $(otherDesk)
        added = true
        return false

    $(desk).appendTo @$('div.unassigned-list') if not added

  seatStudent: (html, status) =>
    [ row, col ] = [ status.get('row'), status.get('col') ]
    @$("#seat-#{row}-#{col}").html(html)

  makeDroppable: =>
    # Drop into a seat
    @$('div.classroom-seat').droppable
      accept: 'div.student-desk'
      hoverClass: 'desk-hover'
      over: (event, ui) ->
        $(this).addClass "desk-taken" if !$(this).is(":empty")
      out: ->
        $(this).removeClass "desk-taken"
      drop: (event, ui) =>
        seat = $(event.target)
        seat.removeClass "desk-taken"
        if seat.is(":empty")
          seat.append $(ui.draggable)
          @trigger 'student-dragged'

    # Drop into the unassigned list
    @$('div.unassigned-list').droppable
      accept: 'div.student-desk'
      hoverClass: 'unassigned-hover'
      drop: (event, ui) =>
        @unseatStudent $(ui.draggable)
        @trigger 'student-dragged'

  studentDragged: =>
    @saveSeatingChart()
    @toggleInstructions()

  toggleInstructions: =>
    seated = @anySeatedStudents()
    @$("#classroom-instructions").toggle(not seated)
    @$("#unassigned-instructions").toggle(seated)

  hideInstructions: =>
    @$("#classroom-instructions, #unassigned-instructions").hide()

  showMarkAllButtons: ->
    @$('.attendance-selector').show()

  hideMarkAllButtons: ->
    @$('.attendance-selector').hide()

  setupMagnificationSlider: ->
    @$('div#classroom-slider').slider
      min: 1800
      max: 3200
      value: 1800
      slide: (event, slider) =>
        magnify = slider.value
        @$('div.grid-container').css({ width : magnify + 201, height : magnify + 201 })
        @$('div.classroom-container').css({ width : magnify, height : magnify })

        if slider.value < 2300
          @$('div.classroom-container').removeClass('large-grid').addClass 'small-grid'

        else if slider.value > 2800
          @$('div.classroom-container').removeClass('small-grid').addClass 'large-grid'

        else
          @$('div.classroom-container').removeClass('small-grid').removeClass 'large-grid'

  setupUnassignedScroll: =>
    $(window).scroll =>
      dist = $(document).scrollTop()

      if dist > 152
        scrollBy = dist - 152
      else
        scrollBy = 0

      @$("div.unassigned-list-container").css "margin-top", scrollBy

  render: =>
    @$el.html(@template())
    @addAll()
    @makeDroppable()
    @setupMagnificationSlider()
    @setupUnassignedScroll()

    return this
