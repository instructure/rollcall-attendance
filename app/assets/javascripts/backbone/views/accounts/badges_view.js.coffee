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

InstructureRollcall.Views.Accounts ||= {}

class InstructureRollcall.Views.Accounts.BadgesView extends Backbone.View
  tagName: "div"
  id: "accounts-badges-view"

  template: JST["backbone/templates/accounts/badges"]

  events:
    "click #add-badge-button" : "badgeDialog"

  initialize: ->
    @account_id = @options.account_id
    @badges = new InstructureRollcall.Collections.BadgesCollection()
    @badges.bind 'reset', @render, this
    @badges.fetch(data: $.param(account_id: @options.account_id))

  renderBadges: =>
    new InstructureRollcall.Views.Badges.IndexView(
      el: @$('#current-badges'),
      badges: @badges
    ).renderPage()

  badgeDialog: =>
    badge = new InstructureRollcall.Models.Badge(account_id: @account_id)
    badge.on 'sync', (->
      @badges.add(badge)
      badge.off('sync', null, this)
    ), this
    new InstructureRollcall.Views.Badges.EditView(model: badge)
    
  render: ->
    @$el.html(@template())
    @renderBadges()
    return this
