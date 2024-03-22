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

Dir[Rails.root.join('lib/readiness_check/*')].each {|file| require file}

module ReadinessCheck

  HTTP_200 = 200.freeze
  HTTP_500 = 500.freeze
  HTTP_503 = 503.freeze

  def status_unhealthy?(status)
    return true if status == HTTP_503

    false
  end

  def components_json
    components = Probe.new.add_components(
      ReadinessCheck::PostgreSql.new,
      ReadinessCheck::Redis.new,
      ReadinessCheck::S3.new
    )
  end

  def app_healthy?
    !!FileUtils.touch('/tmp')
  rescue Errno::EACCES
    false
  end

  def app_status?
    return true if app_healthy? && ReadinessCheck::PostgreSql.new.method

    false
  end

end
