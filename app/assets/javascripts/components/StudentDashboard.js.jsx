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

const StudentDashboard = React.createClass({
  displayName: 'StudentDashboard',

  componentDidMount: function() {
    StudentStore.fetchSummary(this.summaryUpdated);
    StudentStore.fetchDates(1, this.datesUpdated);
    window.addEventListener('scroll', this.handleScroll);
  },

  getInitialState: function() {
    return {};
  },

  render: function() {
    return (
      <div>
        <h1 className="student-header">Roll Call Attendance</h1>
        {this.renderChildren()}
      </div>
    )
  },
  renderChildren: function() {
    if (this.isLoaded()) {
      return (
        <div>
          <div>
            <div className="col-3">
              <AttendanceChart chartData={this.state.summary} />
            </div>
            <div className="col-2">
              <AttendanceTotals data={this.state.summary} />
            </div>
            <div className="col-3">
              <SubmissionScore grade={this.state.summary.grade} />
            </div>
          </div>
          <div>
            <div className="col-8">
              <DatesTable dates={this.state.dates} tardyWeight={this.state.summary.tardy_weight}/>
            </div>
          </div>
        </div>
      );
    } else {
      return <Loading />;
    }
  },
  summaryUpdated: function(data) {
    this.setState({ summary: data });
  },
  datesUpdated: function(data) {
    this.setState({ dates: data });
  },
  isLoaded: function() {
    return !!(this.state.summary && this.state.dates);
  },
  handleScroll: function(e) {
    if (!this.isLoaded()) return;
    if ($(window).scrollTop() + $(window).height() == $(document).height()) {
      if (StudentStore.hasMoreDateRecords()) {
        StudentStore.fetchNextPageOfDates(this.datesUpdated);
      }
    }
  }
});
