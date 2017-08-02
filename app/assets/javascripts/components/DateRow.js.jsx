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

const DateRow = React.createClass({
  displayName: 'DateRow',

  propTypes: {
    data: React.PropTypes.shape({
      class_date: React.PropTypes.string.isRequired,
      attendance: React.PropTypes.string.isRequired
    }).isRequired,
    tardyWeight: React.PropTypes.number.isRequired
  },

  render: function() {
    let date = moment(this.props.data.class_date);
    return (
      <tr>
        <td>{this.renderBullet()}</td>
        <td>{date.format('MMM D')}</td>
        <td>{date.format('dddd')}</td>
        <td>{this.capitalize(this.props.data.attendance)}</td>
        <td>{this.pointsGiven()}</td>
      </tr>
    );
  },

  renderBullet: function() {
    let color = this.props.data.attendance === 'absent' ? '#D0021B' : '#F5A623';

    return (
      <span className="fa fa-circle" style={ { color: color } } />
    );
  },

  capitalize: function(str) {
    return str.substring(0, 1).toUpperCase() + str.substring(1);
  },

  pointsGiven: function() {
    let percentage = this.props.tardyWeight * 100;
    if (this.props.data.attendance === 'absent') {
      return '0%';
    } else {
      return percentage + '%';
    }
  }
});
