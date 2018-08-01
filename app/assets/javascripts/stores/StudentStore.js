/*
 * Copyright (C) 2016 - present Instructure, Inc.
 *
 * This file is part of Rollcall.
 *
 * Rollcall is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License as published by the Free
 * Software Foundation, version 3 of the License.
 *
 * Rollcall is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Affero General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

var StudentStore = {
  summary: {},
  dates: [],
  datesMeta: {},
  defaultAjaxOptions: function() {
    return {
      dataType: 'json',
      headers: {
        'Authorization': 'Bearer ' + ENV.jwt_token
      },
      error: this.genericErrorHandler
    };
  },

  fetchSummary: function(cb) {
    var opts = $.extend({
      success: function(data) {
        this.summary = data;
        if (typeof(cb) === 'function') {
          cb(data);
        }
      }.bind(this)
    }, this.defaultAjaxOptions());
    $.ajax('/courses/' + ENV.course_id + '/students/' + ENV.student_id + '/student_statuses/summary', opts);
  },

  fetchDates: function(page, cb) {
    if (typeof(page) === 'undefined') page = 1;

    var opts = $.extend({
      data: {
        attendance_scope: ['absent', 'late'],
        page: page
      },
      success: function(data) {
        this.dates = this.dates.concat(data.data);
        this.datesMeta = data.meta;
        if (typeof(cb) === 'function') {
          cb(this.dates);
        }
      }.bind(this)
    }, this.defaultAjaxOptions());

    $.ajax('/courses/' + ENV.course_id + '/students/' + ENV.student_id + '/student_statuses', opts);
  },

  genericErrorHandler: function() {
    alert("An error occurred while processing your request");
  },

  hasMoreDateRecords: function() {
    return typeof(this.datesMeta.current_page) === 'undefined' || this.datesMeta.current_page < this.datesMeta.total_pages
  },

  fetchNextPageOfDates: function(cb) {
    nextPage = this.datesMeta.current_page ? this.datesMeta.current_page + 1 : 1
    this.fetchDates(nextPage || 1, cb);
  }
};
