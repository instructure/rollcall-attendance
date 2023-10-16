describe "Award", ->
  award = null

  beforeEach ->
    award = new InstructureRollcall.Models.Award()

  describe "toggle sync", ->
    it "instantiates the ToggleSync mixin", ->
      spy = spyOn(award, 'initializeToggleSync')
      award.initialize()
      expect(spy).toHaveBeenCalled()

  describe "toggledOff", ->
    beforeEach ->
      spyOn(award, 'queueSave')

    describe "when having been toggled off", ->
      it "is true", ->
        award.toggleOff()
        expect(award.toggledOff()).toBeTruthy()

    describe "when having been toggled on", ->
      it "is false", ->
        award.toggleOn()
        expect(award.toggledOff()).toBeFalsy()

  describe "toggleOn and toggleOff", ->
    beforeEach ->
      @save = spyOn(award, 'queueSave')

    it "saves when toggling on", ->
      award.toggleOn()
      expect(@save).toHaveBeenCalled()

    it "saves when toggling off", ->
      award.toggleOff()
      expect(@save).toHaveBeenCalled()

  describe "toggle", ->
    beforeEach ->
      spyOn(award, 'queueSave')

    describe "when the badge has not been awarded", ->
      it "toggles on", ->
        toggleOn = spyOn(award, 'toggleOn')
        award.toggleOff()
        award.toggle()
        expect(toggleOn).toHaveBeenCalled()

    describe "when the badge has been awarded", ->
      it "toggles off", ->
        toggleOff = spyOn(award, 'toggleOff')
        award.toggleOn()
        award.toggle()
        expect(toggleOff).toHaveBeenCalled()
