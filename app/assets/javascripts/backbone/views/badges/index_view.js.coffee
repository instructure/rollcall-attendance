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

class InstructureRollcall.Views.Badges.IndexView extends Backbone.View
  modal_template : JST["backbone/templates/badges/index_modal"]
  template : JST["backbone/templates/badges/index"]

  initialize: ->
    _.bindAll this, "render"
    @badges = @options.badges
    @badges.bind 'destroy', ((badge) -> @badges.remove(badge)), this
    @badges.bind 'sync add', @renderBadges, this

  renderBadges: =>
    @$('.manage-badge-list').html('')

    _.each @badges.models, (badge) =>
      view = new InstructureRollcall.Views.Badges.BadgeView(model: badge, indexView: this)
      @$('.manage-badge-list').append(view.render().el)

  renderDialog : ->
    @$el = $(@modal_template()).dialog
      height: 380
      width: 600
      minWidth: 500
      modal: true

    @delegateEvents()
    @renderBadges()
    return this

  renderPage: ->
    @$el.html(@template())
    @delegateEvents()
    @renderBadges()
    return this
