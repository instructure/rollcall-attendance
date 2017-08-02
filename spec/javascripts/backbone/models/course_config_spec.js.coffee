describe "CourseConfig", ->
  describe "tardyWeightPercentage", ->
    beforeEach ->
      @config = new InstructureRollcall.Models.CourseConfig()

    it "defaults to 80", ->
      expect(@config.tardyWeightPercentage()).toEqual(80)

    it "is based on the tardy weight", ->
      @config.set "tardy_weight", 0.75
      expect(@config.tardyWeightPercentage()).toEqual(75)
