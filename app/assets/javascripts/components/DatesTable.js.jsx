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

const DatesTable = React.createClass({
  displayName: 'DatesTable',

  propTypes: {
    dates: React.PropTypes.array.isRequired,
    tardyWeight: React.PropTypes.number.isRequired
  },

  render: function() {
    return (
      <table className="student-table">
        <thead>
          <tr>
            <th></th>
            <th>Date</th>
            <th>Day</th>
            <th>Status</th>
            <th>% Points</th>
          </tr>
        </thead>
        <tbody>
          {this.renderDateRows()}
        </tbody>
      </table>
    );
  },

  renderDateRows: function() {
    let rows = this.props.dates.map(function(date) {
      return <DateRow data={date} key={date.id} tardyWeight={this.props.tardyWeight} />;
    }.bind(this));

    return rows;
  }
});
