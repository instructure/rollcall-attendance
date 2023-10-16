describe "CourseConfig", ->
  describe "tardyWeightPercentage", ->
    beforeEach ->
      @config = new InstructureRollcall.Models.CourseConfig()

    it "defaults to 80", ->
      expect(@config.tardyWeightPercentage()).toEqual(80)

    it "is based on the tardy weight", ->
      @config.set "tardy_weight", 0.75
      expect(@config.tardyWeightPercentage()).toEqual(75)

  describe "omitFromFinalGrade", ->
    beforeEach ->
      @config = new InstructureRollcall.Models.CourseConfig()

    it "defaults to false", ->
      expect(@config.omitFromFinalGrade()).toEqual(false)

    it "allows you to set it", ->
      @config.setOmitFromFinalGrade(true)
      expect(@config.omitFromFinalGrade()).toEqual(true)
