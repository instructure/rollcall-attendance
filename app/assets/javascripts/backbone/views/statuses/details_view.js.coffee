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

class InstructureRollcall.Views.Statuses.DetailsView extends Backbone.View
  tagName: "div"
  id: "details-view"

  template: JST["backbone/templates/statuses/details"]

  events:
    "click ul.detail-attendance-toggle li" : "toggleStudent"
    "click #add-custom-toggle" : "badgeDialog"
    "click .manage-badges" : "manageBadgesDialog"
    "click #click-away" : "detach"

  initialize: ->
    @indexView = @options.indexView
    @statusView = @options.statusView

    @awards = new InstructureRollcall.Collections.AwardsCollection()
    @awards.bind 'reset', @renderAwards

    @badges = new InstructureRollcall.Collections.BadgesCollection()
    @badges.fetchForCourse(@indexView.courseId)
    @badges.bind 'destroy remove sync add', @refreshAwards

    _.bindAll this, "render"
    @model.bind 'change', @setActiveToggle
    @model.bind 'sync', @updateStats

  detach: => @indexView.detachDetailsView(this)

  toggleStudent: (event) ->
    event.preventDefault()

    target = $(event.currentTarget)

    if target.hasClass 'toggle-present'
      @model.markAsPresent()
    else if target.hasClass 'toggle-late'
      @model.markAsLate()
    else if target.hasClass 'toggle-absent'
      @model.markAsAbsent()
    else if target.hasClass 'toggle-unmarked'
      @model.unmark()

  badgeDialog: =>
    badge = new InstructureRollcall.Models.Badge(course_id: @indexView.courseId)
    badge.on 'sync', (->
      @badges.add(badge)
      badge.off('sync', null, this)
    ), this
    new InstructureRollcall.Views.Badges.EditView(model: badge)
    
  manageBadgesDialog: =>
    new InstructureRollcall.Views.Badges.IndexView(badges: @badges).renderDialog()

  setActiveToggle: =>
    @$('ul.detail-attendance-toggle li').removeClass('active-toggle').filter(".toggle-#{@model.attendance()}").addClass("active-toggle")
    @$('.attendance-label').text(@model.attendance())

  updateStats: =>
    _.each @model.get('stats'), (value, key) =>
      if key == 'attendance_grade' and value == null
        value = 'N/A'

      @$(".stats-#{key}").text(value)
      
  formatStudentName: (name) -> name.replace /([^ ][\w\-\']+)$/, "<strong>$1</strong>"

  refreshAwards: =>
    @awards.fetchForStudent(@model.get('course_id'), @model.get('student_id'), @indexView.classDate.toString("yyyy-MM-dd"))
    @refreshAwardStats()

  refreshAwardStats: =>
    @awards.statsForStudent @model.get('course_id'), @model.get('student_id'), (stats) ->
      markup = ''
      for label, count of stats
        markup += "<li>#{label}: <strong>#{count}</strong></li>"
      @$('.badge-stats').html(markup)

  renderAwards: =>
    @$('.badge-list').html('')
    _.each @awards.models, (award) =>
      awardView = new InstructureRollcall.Views.Awards.AwardView(model: award, detailsView: this)
      @$('.badge-list').append(awardView.render().el)
      @$('.badge-list').append("&nbsp;")

  templateOptions: ->
    options = @model.toJSON()
    options.formatted_student_name = @formatStudentName(options.student.name)
    options.first_name = @model.firstName()
    options.attendance = @model.attendance()
    options.class_date = @indexView.prettyClassDate()
    return options

  enableClickAway: ->
    @$el.prepend "<div id='click-away'></div>"

  render: ->
    @$el.html(@template(@templateOptions()))
    @refreshAwards()
    @updateStats()
    @setActiveToggle()
    return this
