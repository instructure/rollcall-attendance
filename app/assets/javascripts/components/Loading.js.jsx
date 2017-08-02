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

const Loading = React.createClass({
  displayName: 'Loading',
  render: function() {
    return (
      <div className="loading-icon">
        <img src="/images/panda-cycle-loader.gif" alt="The student dashboard is loading" />
      </div>
    )
  }
})
