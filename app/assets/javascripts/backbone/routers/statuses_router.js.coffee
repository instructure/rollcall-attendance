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

class InstructureRollcall.Routers.StatusesRouter extends Backbone.Router
  initialize: (options) ->
    @statuses = new InstructureRollcall.Collections.StatusesCollection()
    @section_list = new InstructureRollcall.Collections.SectionsCollection()
    @sectionId = options.sectionId
    @courseId = options.courseId
    @courseConfig = options.courseConfig
    new InstructureRollcall.Views.CourseConfigs.SettingsView({model: @courseConfig});

  routes:
    "index"    : "index"
    ":id/edit" : "edit"
    ":id"      : "show"
    ".*"       : "index"

  index: ->
    @view = new InstructureRollcall.Views.Statuses.IndexView(statuses: @statuses, sectionId: @sectionId, courseId: @courseId, courseConfig: @courseConfig, section_list: @section_list)
    $("#statuses").html(@view.render().el)

  show: (id) ->
    status = @statuses.get(id)

    @view = new InstructureRollcall.Views.Statuses.ShowView(model: status)
    $("#statuses").html(@view.render().el)

  edit: (id) ->
    status = @statuses.get(id)

    @view = new InstructureRollcall.Views.Statuses.EditView(model: status)
    $("#statuses").html(@view.render().el)
