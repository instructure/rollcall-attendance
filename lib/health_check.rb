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

class HealthCheck
  def healthy?
    database_healthy? && filesystem_healthy?
  end

  private

  def database_healthy?
    result = ActiveRecord::Base.connection.execute("SELECT '1' AS check")
    ((result && result.first) || {})["check"] == "1"
  rescue StandardError
    # TODO: once all envs are on PG, we should be more specific and rescue
    # PG::ConnectionBad rather than a generic error like this
    false
  end

  def filesystem_healthy?
    !!FileUtils.touch("/tmp")
  rescue Errno::EACCES
    false
  end
end
