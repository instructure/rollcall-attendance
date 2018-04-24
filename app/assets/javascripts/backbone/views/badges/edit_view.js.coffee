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

class   InstructureRollcall.Views.Badges.EditView extends Backbone.View
  template : JST["backbone/templates/badges/edit"]

  events:
    "click .option-icon" : "chooseIcon"
    "click .option-color" : "chooseColor"
    "click .save-button" : "save"

  initialize: ->
    _.bindAll this, "render"
    @renderDialog()

  save: =>
    @model.save {name: @$("input[name=name]").val()},
      success: =>
        @model.trigger 'sync'
      error: =>
        alert "Please fill out all of the fields and try again"

  chooseIcon: (event) =>
    event.preventDefault()
    @$("div.option-color:first").focus()
    @model.set 'icon', @$(event.target).data('icon')
    @setSelectedIcon()

  setSelectedIcon: ->
    @$("div.option-icon").removeClass("chosen").addClass("not-chosen")
    @$("div.option-icon[data-icon='#{@model.get 'icon'}']").addClass("chosen").removeClass("not-chosen")
  
  chooseColor: (event) =>
    event.preventDefault()
    @$(".save-button").focus()
    @model.set 'color', @$(event.target).data('color')
    @setSelectedColor()

  setSelectedColor: ->
    @$("div.option-color").removeClass("chosen").addClass("not-chosen")
    @$("div.option-color[data-color='#{@model.get 'color'}']").addClass("chosen").removeClass("not-chosen")
    @$("div.option-icon").removeClass("default-color").css "color", @model.get('color')

  paintColorOptions: ->
    @$("div.option-color").each ->
      $(this).css "color", $(this).data("color")

  icons:
    Approve: "l"
    Disapprove: "L"
    Star: "*"
    Chat: "b"
    Pencil: "e"
    Exclamation: "!"
    Award: ")"
    Up: "-"
    Down: "/"
    Plus: "+"
    Question: "?"
    Loud: "Y"

  colors:
    "dark gray": "#333"
    "gray" : "#666"
    "green" : "#90b027"
    "red" : "#db1616"
    "yellow" : "#f39f00"
    "blue" : "#194a82"
    "purple" : "#944fa1"
    "brown" : "#613f30"

  templateOptions: ->
    options = @model.toJSON()
    options.name = _.escape(options.name)
    options.icons = @icons
    options.colors = @colors
    options

  renderDialog: ->
    @$el = $(@template(@templateOptions())).dialog
      height: 380
      width: 600
      minWidth: 500
      modal: true

    @model.on 'sync', (->
      @model.off('sync', null, this)
      @$el.dialog('close')), this

    @delegateEvents()
    @setSelectedIcon()
    @setSelectedColor()
    @paintColorOptions()
    return this
