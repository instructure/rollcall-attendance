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

class InstructureRollcall.Views.Statuses.StatusView extends Backbone.View
  ENTER_KEY = 13
  SPACEBAR_KEY = 32

  tagName: "li"

  template: JST["backbone/templates/statuses/status"]

  events:
    "click a.student-toggle" : "clickTogglePresence"
    "keydown a.student-toggle" : "keyTogglePresence"
    "click a.student-detail-toggle-link" : "toggleDetails"

  initialize: ->
    _.bindAll this, "render"
    @model.bind 'change', @setClass
    @model.bind 'change', @updateStatusText
    @indexView = @options.indexView

  clickTogglePresence: (event) ->
    event.preventDefault()
    @model.togglePresence()

  keyTogglePresence: (event) ->
    event.preventDefault()
    if (event.which == SPACEBAR_KEY or event.which == ENTER_KEY)
      @model.togglePresence()

  toggleDetails: (event) =>
    event.preventDefault()

    if @detailsView?
      @indexView.detachDetailsView(@detailsView)
    else
      @showDetails()

  topPosition: -> "#{@$el.position().top}px"

  showDetails: =>
    @detailsView = new InstructureRollcall.Views.Statuses.DetailsView(model: @model, indexView: @indexView, statusView: this)
    @indexView.attachDetailsView(@detailsView)

  setClass: =>
    classes = _.compact [
      @model.attendance(),
      ('has-avatar' if @model.get('student').avatar_url),
      ('details-active' if @detailsView?)
    ]

    @$el.attr 'class', classes.join(' ')

  updateStatusText: =>
    @$('.student-status').text(@model.attendance())

  sectionName: (section_id) ->
    name = ''
    name = $('#section_select').find("option[value=#{section_id}]").text()
    if !name
      $('#sections-select-modal').text().trim()
    else
      name


  templateOptions: ->
    options = @model.toJSON()
    student = if options.student.name then options.student else options.student.user.table
    options.formatted_student_name = @formatStudentName(student.name)
    options.escaped_student_name = _.escape(student.name)
    options.section_name = @sectionName(@model.sectionId())
    options.default_section_id = @indexView.sectionId
    return options

  render: ->
    @$el.html(@template(@templateOptions()))
    @setClass()
    return this

_.extend InstructureRollcall.Views.Statuses.StatusView.prototype, InstructureRollcall.Mixins.Formatting.prototype
