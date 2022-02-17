class InstructureRollcall.Models.Section extends Backbone.Model
  paramRoot: 'section'

  defaults:
    name: null
    course_id: null
    sis_id: null

  initialize: =>

class InstructureRollcall.Collections.SectionsCollection extends Backbone.Collection
  model: InstructureRollcall.Models.Section
  url: '/sections'
