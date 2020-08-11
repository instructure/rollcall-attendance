#
# Copyright (C) 2020 - present Instructure, Inc.
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

describe "Formatting", ->
  view = null

  beforeEach ->
    view = new Backbone.View()
    _.extend view, InstructureRollcall.Mixins.Formatting.prototype

  describe "formatStudentName", ->
    describe "with one word", ->
      it "does not make it strong", ->
        expect(view.formatStudentName("test")).toEqual("test")

    describe "with two words", ->
      it "makes the last name strong", ->
        expect(view.formatStudentName("test test")).toEqual("test <strong>test</strong>")

    describe "with a dash", ->
      it "makes the hyphenated last name strong", ->
        expect(view.formatStudentName("test test-test")).toEqual("test <strong>test-test</strong>")

    describe "with an apostrophe", ->
      it "makes the apostrophe'd last name strong", ->
        expect(view.formatStudentName("test test'test")).toEqual("test <strong>test&#x27;test</strong>")

    describe "with a final word in parentheses or non-word characters", ->
      it "does not make any word strong with parentheses", ->
        expect(view.formatStudentName("test test (test)")).toEqual("test test (test)")

      it "does not make any word strong if they are non-word characters", ->
        expect(view.formatStudentName("test test $$$$")).toEqual("test test $$$$")

    describe "XSS", ->
      it "escapes the name to avoid XSS issues", ->
        expect(view.formatStudentName("<script>window.alert('display');</script>")).toEqual("&lt;script&gt;window.alert(&#x27;display&#x27;);&lt;&#x2F;script&gt;")

