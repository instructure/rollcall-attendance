#
# Copyright (C) 2018 - present Instructure, Inc.
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

module ResqueStats
  def before_perform(*args)
    stats = Resque.info
    %i[pending processed workers working failed].each do |stat|
      CanvasStatsd::Statsd.gauge("resque.#{stat}", stats[stat])
    end
  end

  def around_perform(*args)
    job = self.name.underscore
    stats = ["resque.perform", "resque.perform.#{job}"]
    CanvasStatsd::Statsd.time(stats) do
      yield
    end
  end
end
