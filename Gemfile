# frozen_string_literal: true

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

source "https://rubygems.org"

gem 'logger'
gem 'nokogiri', '>= 1.18.3'
gem "bootsnap", "~> 1.0", require: false
gem "bundler", ">= 2.4.16"
gem "rack", "~> 2.1"
gem "rails", "7.0.7"
gem "concurrent-ruby", "= 1.3.4"

gem "thin", "~> 1.7.0"

gem "canvas_oauth_engine", "~> 2.4.0", require: "canvas_oauth"
gem "httparty", "~> 0.17.0"
gem "ims-lti", "~> 1.0", require: "ims"
gem "lti_provider_engine", "~> 1.2.3", require: "lti_provider"

gem "aws-sdk-s3", "~> 1.0"
gem "redis", "~> 5.0"
gem "redlock", "~> 2.0"
gem "sinatra"
gem "sinatra-contrib", require: false
gem "inst-jobs-statsd"

gem "chronic", "~> 0.10"
gem "json", "~> 2.0"
gem "responders", "3.0.1"
gem "rufus-scheduler", "~> 3.9"

gem "inst_statsd", "~> 2.1.4"
gem "paul_bunyan", "~> 2.1.0"
gem "sentry-raven", "~> 2.0"

gem "coffee-rails", "~> 5.0.0"
gem "coffee-script", "2.2.0"
gem "font-awesome-rails", "~> 4.7.0"
gem "jquery-rails", "~> 4.6.0"
gem "jquery-ui-rails", "~> 6.0"
gem "jwt", "~> 1.5.4"
gem "momentjs-rails", "~> 2.11", ">= 2.11.1"
gem "rails-backbone", "~> 0.7.2"
gem "rails-html-sanitizer", "1.6.0"
gem "react-rails", "~> 1.7"
gem "rexml", "~> 3.2.4"
gem "sass-rails", "~> 6.0.0"
gem "uglifier", "~> 4.0"
gem "webdrivers"
gem "will_paginate", "~> 4.0.0"

group :development, :test do
  gem "byebug"
  gem "guard-jasmine"
  gem "jasmine-core", "2.99.2"
  gem "jasmine-rails"
  gem "minitest"
  gem "phantomjs"
  gem "rspec-collection_matchers"
  gem "rspec-its"
  gem "rspec-rails", "~> 6.0.3"
  gem "test-unit"
  # We can relax this brakeman dependency after we have deployed a hybrid
  # cookie serializer and allowed a chance for cookies to be stored as JSON.
  gem "brakeman", "6.0.1", require: false
  gem "rubocop", "~>1.60", require: false
  gem "rubocop-performance", "~>1.20", require: false
  gem "rubocop-rails", "~>2.23", require: false
  gem "rubocop-rspec", "~>2.26", require: false
end

group :test do
  gem "cucumber-rails", require: false
  gem "database_cleaner"
  gem "selenium-webdriver"
  gem "shoulda"
  gem "webmock", "3.19.1"
  # Capybara-webkit breaks with capybara 3, so we'll stay at the latest version 2
  gem "capybara", "~> 3.39"
  gem "puma"
  # upgrades are unstable for getting webkit running in all test environments,
  # will need to upgrade capybara-webkit as it's own commit and step up background
  # dependencies (like QT & xvfb) on all platforms that run cucumber tests as part of a single
  # upgrade
  gem "capybara-screenshot"
  gem "database_cleaner-active_record"
  gem "factory_bot_rails"
  gem "guard-rspec"
  gem "rails-controller-testing"
  gem "simplecov", require: false
  gem "sprockets-helpers", require: false
end

group :postgres do
  gem "pg", "~> 1.5.3"
end
