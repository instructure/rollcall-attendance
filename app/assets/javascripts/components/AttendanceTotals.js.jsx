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

var AttendanceTotals = React.createClass({
  displayName: 'AttendanceTotals',
  propTypes: {
    data: React.PropTypes.shape({
      present_statuses: React.PropTypes.number.isRequired,
      absent_statuses: React.PropTypes.number.isRequired,
      late_statuses: React.PropTypes.number.isRequired
    }).isRequired
  },
  render: function() {
    return (
      <div className="attendance-totals">
        <div className="total-days">
          {this.renderBullet(this.props.data.late_statuses, "Late Day", '#F5A623')}
          {this.renderBullet(this.props.data.absent_statuses, "Absent Day", '#D0021B')}
          {this.renderBullet(this.props.data.present_statuses, "Present Day", '#7ED321')}
        </div>
      </div>
    );
  },

  renderBullet: function(count, text, color) {
    let pluralizedText = this.pluralize(text, count);
    return (
      <div className="attendance-bullet">
        <span className="fa fa-circle" style={ { color: color } } />
        <span className="attendance-days-count">{count}</span> {pluralizedText}
      </div>
    );
  },

  pluralize: function(str, count) {
    if (count != 1) str += 's';
    return str;
  }
})
