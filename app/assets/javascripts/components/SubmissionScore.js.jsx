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

var SubmissionScore = React.createClass({
  displayName: 'SubmissionScore',
  propTypes: {
    grade: React.PropTypes.string
  },
  render: function() {
    if (!this.props.grade) { return null; }

    return (
      <div className="submission-grade-container">
        <p className="submission-grade">{this.props.grade}</p>
        <p>Current Score</p>
      </div>
    );
  }
});
