describe "StatusesCollection", ->
  it "sorts statuses by the student's name", ->
    statuses = new InstructureRollcall.Collections.StatusesCollection()
    statuses.add({student: { name: "Derek Zoolander", sortable_name: "Zoolander, Derek" }})
    statuses.add({student: { name: "Hansel", sortable_name: "Hansel" }})
    statuses.add({student: { name: "Jacobim Mugatu", sortable_name: "Mugatu, Jacobim" }})
    expect(statuses.at(0).get('student').name).toEqual('Hansel')
    expect(statuses.at(1).get('student').name).toEqual('Jacobim Mugatu')
    expect(statuses.at(2).get('student').name).toEqual('Derek Zoolander')

describe "Status", ->
  beforeEach ->
    @status = new InstructureRollcall.Models.Status()

  describe ".isPresent", ->
    describe "when present", ->
      beforeEach -> @status.set(attendance: 'present')

      it "is true", ->
        expect(@status.isPresent()).toBe(true)

    describe "when absent", ->
      beforeEach -> @status.set(attendance: 'absent')

      it "is false", ->
        expect(@status.isPresent()).toBe(false)

  describe ".isAbsent", ->
    describe "when absent", ->
      beforeEach -> @status.set(attendance: 'absent')

      it "is true", ->
        expect(@status.isAbsent()).toBe(true)

    describe "when present", ->
      beforeEach -> @status.set(attendance: 'present')

      it "is false", ->
        expect(@status.isAbsent()).toBe(false)

  describe ".isLate", ->
    describe "when late", ->
      beforeEach -> @status.set(attendance: 'late')

      it "is true", ->
        expect(@status.isLate()).toBe(true)

  describe ".isUnmarked", ->
    describe "when null", ->
      beforeEach -> @status.set(attendance: null)

      it "is true", ->
        expect(@status.isUnmarked()).toBe(true)

    describe "when present", ->
      beforeEach -> @status.set(attendance: 'present')

      it "is false", ->
        expect(@status.isUnmarked()).toBe(false)

  describe "toggling presence", ->
    beforeEach ->
      @save = spyOn(@status, 'queueSave')

    describe ".markAsPresent", ->
      beforeEach -> @status.markAsPresent()

      it "marks the attendance as present", ->
        expect(@status.get('attendance')).toBe('present')

      it "saves", -> expect(@save).toHaveBeenCalled()

    describe ".markAsAbsent", ->
      beforeEach -> @status.markAsAbsent()

      it "marks the @status as absent", ->
        expect(@status.get('attendance')).toBe('absent')

      it "saves", -> expect(@save).toHaveBeenCalled()

    describe ".markAsLate", ->
      beforeEach -> @status.markAsLate()

      it "marks the @status as late", ->
        expect(@status.get('attendance')).toBe('late')

      it "saves", -> expect(@save).toHaveBeenCalled()

    describe ".togglePresence", ->
      describe "when present", ->
        it "marks as absent", ->
          @status.markAsPresent()
          spy = spyOn(@status, 'markAsAbsent')
          @status.togglePresence()
          expect(spy).toHaveBeenCalled()

      describe "when absent", ->
        it "marks as late", ->
          @status.markAsAbsent()
          spy = spyOn(@status, 'markAsLate')
          @status.togglePresence()
          expect(spy).toHaveBeenCalled()

      describe "when late", ->
        it "marks as unmarked", ->
          @status.markAsLate()
          spy = spyOn(@status, 'unmark')
          @status.togglePresence()
          expect(spy).toHaveBeenCalled()

      describe "when unmarked", ->
        it "marks as present", ->
          @status.set('attendance', null)
          spy = spyOn(@status, 'markAsPresent')
          @status.togglePresence()
          expect(spy).toHaveBeenCalled()

  describe ".sectionId", ->
    beforeEach -> @status.set(section_id: '1')

    it "gets the section id", ->
      expect(@status.sectionId()).toBe('1')

  describe "unmark", ->
    beforeEach ->
      @status.set({id: 1, attendance: 'present'})
      @spy = spyOn(@status, 'queueSave')
      @status.unmark()

    it "unsets the attendance", ->
      expect(@status.get('attendance')).toBeNull()

    it "deletes the record", ->
      expect(@spy).toHaveBeenCalled()

  describe "delete", ->
    beforeEach ->
      @status.set(id: 1)
      @sync = spyOn(Backbone, 'sync')
      @status.delete()

    it "unsets the ID", ->
      expect(@status.get('id')).toBeNull()

    it "syncs", ->
      expect(@sync).toHaveBeenCalled()

  describe "firstName", ->
    it "returns the first name", ->
      @status.set('student', name: 'Twelve Spokes')
      expect(@status.firstName()).toEqual('Twelve')

  describe "toggle sync", ->
    it "instantiates the ToggleSync mixin", ->
      spy = spyOn(@status, 'initializeToggleSync')
      @status.initialize()
      expect(spy).toHaveBeenCalled()
