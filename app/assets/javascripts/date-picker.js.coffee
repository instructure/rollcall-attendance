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

(($)->
  $ ->
    start = $("[data-date-range-picker] input[data-date-range-picker-from]")
    end = $("[data-date-range-picker] input[data-date-range-picker-to]")
    sisCourseId = $("#report_sis_course_id")
    sisStudentId = $("#report_sis_student_id")

    hasSisFilter = ->
      $.trim(sisCourseId.val()) or $.trim(sisStudentId.val())

    updateEnd = ->
      end.datepicker "option",
        minDate: null
        maxDate: null
      return if hasSisFilter()

      selectedDate = start.datepicker("getDate")
      return unless $.trim(selectedDate)

      end.datepicker("option", "minDate", selectedDate)
      if rangeSize = end.parents('[data-date-range-picker]').data('dateRangePickerSize')
        sevenDaysAhead = new Date(selectedDate)
        dateOffset = selectedDate.getDate() + rangeSize
        sevenDaysAhead.setDate(dateOffset)
        end.datepicker("option", "maxDate", sevenDaysAhead)

    updateStart = ->
      start.datepicker "option",
        minDate: null
        maxDate: null
      return if hasSisFilter()

      selectedDate = end.datepicker("getDate")
      return unless $.trim(selectedDate)

      start.datepicker("option", "maxDate", selectedDate)
      if rangeSize = start.parents('[data-date-range-picker]').data('dateRangePickerSize')
        sevenDaysAhead = new Date(selectedDate)
        dateOffset = selectedDate.getDate() - rangeSize
        sevenDaysAhead.setDate(dateOffset)
        start.datepicker("option", "minDate", sevenDaysAhead)

    updateEndThenStart = ->
      updateEnd()
      updateStart()

    sisCourseId.blur updateEndThenStart
    sisStudentId.blur updateEndThenStart

    start.datepicker
      onClose: updateEndThenStart

    end.datepicker
      onClose: ->
        updateStart()
        updateEnd()

)(jQuery)
