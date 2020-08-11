describe "StatusView", ->
  describe "#clickTogglePresence", ->
    beforeEach ->
      @fixtures = document.createElement 'div'
      @fixtures .setAttribute 'id', 'fixtures'
      document.body.appendChild @fixtures

      indexView = {}
      @status = new InstructureRollcall.Models.Status()
      @status.set student: { name: "Derek Zoolander" }
      @statusView = new InstructureRollcall.Views.Statuses.StatusView(
        model: @status
        indexView: indexView
      )
      @fixtures.appendChild @statusView.render().el

    afterEach ->
      document.body.removeChild(@fixtures)

    describe "click a.toggle-student", ->
      it "calls clickTogglePresence", ->
        spy = spyOn(@status, 'togglePresence')
        $('a.student-toggle').trigger('click')
        expect(spy).toHaveBeenCalled()

    describe "spacebar a.toggle-student", ->
      it "calls togglePresence on the model", ->
        spy = spyOn(@status, 'togglePresence')
        event = $.Event('keydown', { which: 13 })
        $('a.student-toggle').trigger(event)
        expect(spy).toHaveBeenCalled()

    describe "enter a.toggle-student", ->
      it "calls togglePresence on the model", ->
        spy = spyOn(@status, 'togglePresence')
        event = $.Event('keydown', { which: 32 })
        $('a.student-toggle').trigger(event)
        expect(spy).toHaveBeenCalled()

    describe "a.toggle-student", ->
      it "other keycodes do not togglePresence on the model", ->
        spy = spyOn(@status, 'togglePresence')
        for code in [0..12].concat([14..31].concat([33..128]))
          event = $.Event('keydown', { which: code })
          $('a.student-toggle').trigger(event)
          expect(spy).not.toHaveBeenCalled()

  describe "#templateOptions", ->
    beforeEach ->
      @status = new InstructureRollcall.Models.Status()
      @status.set student: { name: "Snail Mail" }
      statuses = new InstructureRollcall.Collections.StatusesCollection()
      statuses.add(@status)
      statuses.add({student: { name: "Clairo" }})

      @indexView = new InstructureRollcall.Views.Statuses.IndexView(
        statuses: statuses,
        sectionId: '1'
      )

      @statusView = new InstructureRollcall.Views.Statuses.StatusView(
        model: @status,
        indexView: @indexView
      )

    describe ".sectionName", ->
      it "gets the name of the current section", ->
        @select = document.createElement 'select'
        @select .setAttribute 'id', 'section_select'
        document.body.appendChild @select

        @option = document.createElement 'option'
        @option.setAttribute 'value', '1'
        @select.appendChild @option

        $('#section_select').find("option[value=1]").text('Intro to Vaporwave')
        expect(@statusView.sectionName('1')).toBe('Intro to Vaporwave')

    describe "default_section_id", ->
      it "gets index view sectionId", ->
        expect(@statusView.templateOptions().default_section_id).toBe(@indexView.sectionId)
