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

if Rails.env.production?
  require 'raven'

  load_config_for_env = lambda do
    path = File.join(Rails.root, 'config', 'sentry.yml')
    return unless File.exists?(path)

    config = YAML.load_file(path)[Rails.env]
    config.try(:with_indifferent_access)
  end

  config = load_config_for_env.call
  if config
    valid_keys = %w[dsn environments open_timeout timeout ssl_verification tags]
    config = config.slice(*valid_keys)

    Raven.configure do |raven_config|
      config.each do |key, value|
        raven_config.send("#{key}=", value)
      end
      raven_config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    end
  elsif ENV['SENTRY_DSN']
    Raven.configure do |config|
      # TODO: turn back on once we're on >= 0.14.0
      #config.silence_ready = true
      config.ssl_verification = true
      config.tags = { site: ENV['CG_ENVIRONMENT'] }
      config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
    end
  end
end
