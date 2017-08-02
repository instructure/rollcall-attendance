describe "StatusView", ->
  describe ".formatStudentName", ->
    beforeEach ->
      indexView = {}
      @statusView = new InstructureRollcall.Views.Statuses.StatusView(
        model: new InstructureRollcall.Models.Status(),
        indexView: indexView
      )

    describe "with one word", ->
      it "does not make it strong", ->
        expect(@statusView.formatStudentName("test")).toEqual("test")

    describe "with two words", ->
      it "makes the last name strong", ->
        expect(@statusView.formatStudentName("test test")).toEqual("test <strong>test</strong>")

    describe "with a dash", ->
      it "makes the hyphenated last name strong", ->
        expect(@statusView.formatStudentName("test test-test")).toEqual("test <strong>test-test</strong>")

    describe "with an apostrophe", ->
      it "makes the apostrophe'd last name strong", ->
        expect(@statusView.formatStudentName("test test'test")).toEqual("test <strong>test'test</strong>")

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
