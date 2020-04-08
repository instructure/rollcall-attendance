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

config_file = Rails.root.join('config/redis.yml')

redis_uri = if ENV['REDIS2_URL']
              Rails.logger.info "Initializing Redis from REDIS2_URL env var: #{ENV['REDIS2_URL']}"
              ENV['REDIS2_URL']
            elsif ENV['REDIS_URL']
              Rails.logger.info "Initializing Redis from REDIS_URL env var: #{ENV['REDIS_URL']}"
              ENV['REDIS_URL']
            elsif File.exists?(config_file)
              Rails.logger.info "Initializing Redis from #{config_file}"
              YAML::load(File.open(config_file))[Rails.env]['uri']
            else
              default_uri = 'redis://localhost:6379'
              Rails.logger.info "Initializing Redis using default of #{default_uri}"
              default_uri
            end

uri = URI.parse(redis_uri)
$REDIS = Redis.new(host: uri.host, port: uri.port, password: uri.password)
Redis.current = $REDIS
