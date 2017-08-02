describe "ToggleSync", ->
  model = null

  beforeEach ->
    model = new Backbone.Model()
    model.url = '/somewhere'
    model.toggledOff = -> false
    model.set(id: 1)
    _.extend model, InstructureRollcall.Mixins.ToggleSync.prototype
    model.initializeToggleSync(model)

  describe "sync queue", ->
    describe "queueSave", ->
      it "commits when not locked", ->
        model.isLocked = -> false
        commit = spyOn(model, 'commit')
        model.queueSave()
        expect(commit).toHaveBeenCalled()

      it "queues changed parameters to be saved", ->
        model.set 'attendance', 'late'
        spyOn(model, 'commit')
        model.queueSave()
        expect(model.queuedParams.attendance).toEqual('late')

    describe "applyQueue", ->
      beforeEach ->
        model.queuedParams = 'queued'
        
      it "applies the queuedParams", ->
        set = spyOn(model, 'set')
        model.applyQueue()
        expect(set).toHaveBeenCalledWith('queued')

      it "clears out the queuedParams", ->
        model.applyQueue()
        expect(model.queuedParams).toBeNull()

    describe "commitOrUnlock", ->
      it "commits when a save has been requested", ->
        commit = spyOn(model, 'commit')
        model.queuedParams = true
        model.commitOrUnlock()
        expect(commit).toHaveBeenCalled()

      it "unlocks for future saving when a save has not been requested", ->
        unlock = spyOn(model, 'unlock')
        model.queuedParams = null
        model.commitOrUnlock()
        expect(unlock).toHaveBeenCalled()

    describe "commit", ->
      it "locks to prevent interference with other save requests", ->
        lock = spyOn(model, 'lock')
        spyOn(model, 'save')
        model.commit()
        expect(lock).toHaveBeenCalled()

      it "deletes when toggled off", ->
        deleteMethod = spyOn(model, 'delete')
        model.toggledOff = -> true
        model.commit()
        expect(deleteMethod).toHaveBeenCalled()

      it "saves when marked", ->
        save = spyOn(model, 'save')
        model.toggledOff = -> false
        model.commit()
        expect(save).toHaveBeenCalled()
