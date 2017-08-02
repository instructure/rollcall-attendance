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

InstructureRollcall.Views.CourseConfigs ||= {}

class InstructureRollcall.Views.CourseConfigs.SettingsView extends Backbone.View
  template: JST["backbone/templates/course_configs/settings"]

  initialize: ->
    $("a#settings-toggle").live 'click', @render

  setupSlider: ->
    @$("#lateness-percentage-slider").slider
      range: "min"
      min: 0
      max: 100
      value: @model.tardyWeightPercentage()
      slide: @updateTardyWeightPercentage
      change: @saveTardyWeight

    @updateTardyWeightPercentage()

  updateTardyWeightPercentage: (event, ui) =>
    value = if event and ui then ui.value else @model.tardyWeightPercentage()
    
    @$("#lateness-percentage span").html(value)
    @$("#lateness-percentage-slider").attr("aria-valuenow", value).attr("aria-valuetext", "#{value} percent")
    
  saveTardyWeight: (event, ui) =>
    @updateTardyWeightPercentage(event, ui)
    @model.setTardyWeight(ui.value)
    @model.save()

  render : =>
    @$el = $(@template())
    @setupSlider()

    @$el.dialog
      height: 300
      width: 500
      minWidth: 500
      modal: true

    $('.ui-dialog').focus()

    return this
