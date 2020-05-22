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

source 'https://rubygems.org'

gem 'bundler', '>= 1.7.10'

gem 'rails', '~> 5.2.0'
gem 'rack', '~> 2.1'
gem 'bootsnap', '~> 1.0', require: false

gem 'thin', '~> 1.0'

gem 'ims-lti', '~> 1.0', require: 'ims'
gem 'lti_provider_engine', '~> 1.1.0', require: 'lti_provider'
gem 'canvas_oauth_engine', '~> 2.1.3', require: 'canvas_oauth'
gem 'httparty', '~> 0.15'

gem 'aws-sdk-s3', '~> 1.0'
gem 'redis', '~> 4.0'
gem 'redis-objects', '~> 1.0'
gem 'resque', '~> 1.0'
gem 'resque-retry', '~> 1.0'
  gem 'resque-scheduler', '~> 4.3.0'
    # rufus-scheduler 3.5.x breaks resque-scheduler 4.3.1
    gem 'rufus-scheduler', '3.4.2'
gem 'resque-sentry', '~> 1.0'
gem 'chronic', '~> 0.10'
gem 'json', '~> 2.0'
gem 'responders', '~> 2.0'

gem 'sentry-raven', '~> 2.0'
gem 'inst_statsd', '~> 2.1.4'
gem 'paul_bunyan', '~> 1.5'

gem 'sass-rails', '~> 5.0.0'
gem 'coffee-rails', '~> 5.0.0'
gem 'coffee-script', '2.2.0'
gem 'mini_racer', '~> 0.2'
gem 'uglifier', '~> 4.0'
gem 'jwt', '~> 1.5.4'
gem 'will_paginate', '~> 3.1.0'
gem 'react-rails', '~> 1.7'
gem 'momentjs-rails', '~> 2.11', '>= 2.11.1'
gem 'font-awesome-rails', '~> 4.7.0'
gem 'jquery-rails', "~> 4.0"
gem 'jquery-ui-rails', "~> 6.0"
gem 'rails-backbone', "~> 0.7.2"

group :development, :test do
  gem 'byebug'
  gem 'minitest'
  gem 'test-unit'
  gem 'syck'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem 'rspec-collection_matchers'
  gem 'jasmine-rails'
  gem 'phantomjs', '1.9.7.1'
  gem 'guard-jasmine', '~> 2.0'
  # We can relax this brakeman dependency after we have deployed a hybrid
  # cookie serializer and allowed a chance for cookies to be stored as JSON.
  gem 'brakeman', '4.5.1', require: false
  gem 'rubocop', '0.84.0', require: false
  gem 'rubocop-rspec', '1.22.2', require: false
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'shoulda'
  gem 'webmock'
  # Capybara-webkit breaks with capybara 3, so we'll stay at the latest version 2
  gem 'capybara', '2.18.0'
  # upgrades are unstable for getting webkit running in all test environments,
  # will need to upgrade capybara-webkit as it's own commit and step up background
  # dependencies (like QT & xvfb) on all platforms that run cucumber tests as part of a single
  # upgrade
  gem 'capybara-webkit', '1.15.1'
  gem 'capybara-screenshot'
  gem 'factory_bot_rails'
  gem 'guard-rspec'
  gem 'simplecov', require: false
  gem 'sprockets-helpers', require: false
  gem 'rails-controller-testing'
end

group :postgres do
  gem 'pg', '~> 1.0'
end

group :mysql do
  gem 'mysql2', '~> 0.5.2'
end
