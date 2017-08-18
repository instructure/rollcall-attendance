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

gem 'rails', '~> 4.2.9'
gem 'rack'

gem 'thin'

gem 'ims-lti', require: 'ims'
gem 'lti_provider_engine', '~> 1.0.0', require: 'lti_provider'
gem 'canvas_oauth_engine', '~> 2.0.0', require: 'canvas_oauth'
gem 'httparty'

gem 'aws-sdk-s3', '<= 2.0'
gem 'redis'
gem 'redis-objects'
gem 'resque'
gem 'resque-retry'
gem 'resque-sentry'
gem 'foreman'
gem 'chronic'
gem 'json'
gem 'responders', '~> 2.0'

# 0.14.0 has configuration options that aren't the same as what's available in 0.12
# so we're staying on 0.12 until the ruby 2.2 upgrade is cutovere everywhere, then
# this can be unpinned and the TODO in config/raven.rb can be resolved
gem 'sentry-raven', '0.12.2'
gem 'canvas_statsd', '1.0.5'

gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'jwt', '~> 1.5.4'
gem 'will_paginate', '~> 3.1.0'
gem 'react-rails', '~> 1.7'
gem 'momentjs-rails', '~> 2.11', '>= 2.11.1'
gem 'font-awesome-rails', '~> 4.6.3.0'

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
  gem 'guard-jasmine'
end

group :development do
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'shoulda', require: false
  gem 'webmock'
  # upgrades are unstable for getting webkit running in all test environments,
  # will need to upgrade capybara-webkit as it's own commit and step up background
  # dependencies (like QT & xvfb) on all platforms that run cucumber tests as part of a single
  # upgrade
  gem 'capybara-webkit', '1.3.1'
  gem 'capybara-screenshot'
  gem 'factory_girl_rails'
  gem 'guard-rspec'
  gem 'simplecov', require: false
  gem 'sprockets-helpers', require: false
end

group :postgres do
  gem 'pg'
end

group :mysql do
  gem 'mysql2'
end

gem 'nokogiri'

gem 'jquery-rails', "~> 4.0"
gem 'jquery-ui-rails', "~> 6.0"
gem 'rails-backbone', "~>0.7.2"
