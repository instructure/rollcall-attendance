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

require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'active_record'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module InstructureRollcall
  class Application < Rails::Application
    config.active_record.legacy_connection_handling = false
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Add kickstand to asset paths
    config.assets.paths << Rails.root.join("vendor", "assets", "kickstand")

    # Add app/assets/fonts to the asset path
    config.assets.paths << Rails.root.join("app", "assets", "fonts")

    config.action_dispatch.default_headers = { 'X-Frame-Options' => 'ALLOWALL' }

    config.autoload_paths += %w[lib]

    # Our deploy tooling exports a DATABASE_URL like:
    # mysql://user:pass@db:port/database, so handle that
    module MysqlProtocolResolver
      def initialize(url)
        url = url.gsub("mysql://", "mysql2://")
        super(url)
      end
    end
    # ActiveRecord::ConnectionAdapters::ConnectionSpecification::ConnectionUrlResolver.prepend(MysqlProtocolResolver)
    ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
  end
end
