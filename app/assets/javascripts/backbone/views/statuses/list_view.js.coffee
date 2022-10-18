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

class InstructureRollcall.Views.Statuses.ListView extends Backbone.View
  template: JST["backbone/templates/statuses/list"]

  events:
    'click #mark-all-present': 'markAllPresent'
    'click #unmark-all': 'unmarkAll'

  markAllPresent: (event) ->
    event.preventDefault()

    @indexView.statuses.each (status) ->
      status.markAsPresent()

  unmarkAll: (event) ->
    event.preventDefault()

    @indexView.statuses.each (status) ->
      status.unmark()

  initialize: ->
    @indexView = @options.indexView

  addAll: =>
    @$("#student-list").hide().fadeIn(300).html('')
    @$('#student-details').html('')
    @indexView.statuses.each(@addOne)

  checkSection: (sectionId) =>
    sectionOption = $('#section_select')
      .find("option[value=#{sectionId}]")
    selected = sectionOption.is(':selected')
    name = sectionOption.text()
    return true if name != '' and selected
    false

  addOne: (status) =>
    try
      view = new InstructureRollcall.Views.Statuses.StatusView({
        model : status,
        indexView: @indexView
      })
      if @checkSection(status.get('section_id'))
        @$("#student-list").append(view.render().el)
        view.showDetails() if @indexView.detailsView? and
          status.get('student_id') == @indexView.detailsView.model.get('student_id')
    catch error
      alert error.message

  render: =>
    @$el.html(@template())
    @addAll()

    return this
