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

require 'resque/server'

# Resque error handling
# Use multiple error handlers -- sentry and redis (for resque's web interface)
require 'resque/failure/multiple'
require 'resque/failure/redis'
require 'resque-sentry'

raise "No redis defined for resque" if $REDIS.nil?
Resque.redis = $REDIS

Resque::Failure::MultipleWithRetrySuppression.classes = [
  Resque::Failure::Redis,
  Resque::Failure::Sentry
]
Resque::Failure.backend = Resque::Failure::MultipleWithRetrySuppression

class SecureResqueServer < Resque::Server
  use Rack::Auth::Basic, "Restricted Area" do |provided_user, provided_pass|
    config_file = Rails.root.join('config/resque.yml')

    if File.exists?(config_file)
      config = YAML::load(File.open(config_file))[Rails.env]
      user = config['username']
      pass = config['password']
    elsif (user = ENV['RESQUE_USER']) && (pass = ENV['RESQUE_PASS'])
      # ok
    else
      Rails.logger.info "Warning: No username and password set for Resque admin panel! (see resque.yml.sample)"
      return false
    end

    [provided_user, provided_pass] == [user, pass]
  end
end

# this deals with stale database connections that can cause jobs to error with
# "Mysql::Error: MySQL server has gone away" (see https://gist.github.com/defunkt/238999)
Resque.after_fork do
  ActiveRecord::Base.clear_active_connections!
end
