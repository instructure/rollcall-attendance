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

path = File.join(Rails.root, 'config', 'mail.yml')
if File.exists?(path)
  mail_config = YAML.load_file(path)[Rails.env].deep_symbolize_keys
  smtp_settings = mail_config[:smtp]
  default_options = mail_config[:default_options]
else
  smtp_settings = {}
  default_options = {}

  smtp_settings[:address] = ENV['SMTP_ADDRESS']
  smtp_settings[:port] = ENV['SMTP_PORT']
  smtp_settings[:authentication] = ENV['SMTP_AUTHENTICATION']
  smtp_settings[:user_name] = ENV['SMTP_USER_NAME']
  smtp_settings[:password] = ENV['SMTP_PASSWORD']
  smtp_settings[:domain] = ENV['SMTP_DOMAIN']
  smtp_settings[:enable_starttls_auto] = ENV['SMTP_ENABLE_STARTTLS_AUTO']
  smtp_settings[:openssl_verify_mode] = ENV['SMTP_OPENSSL_VERIFY_MODE']
  
  default_options[:outgoing_address] = ENV[OUTGOING_ADDRESS]

  smtp_settings.delete_if { |k,v| v.blank? }
  default_options.delete_if { |k,v| v.blank? }

  if smtp_settings.present?
    smtp_settings[:enable_starttls_auto] = !%w(false False 0).include?(smtp_settings[:enable_starttls_auto])
    smtp_settings[:authentication] = smtp_settings[:authentication].to_sym
  end
end

if smtp_settings.present?
  ActionMailer::Base.smtp_settings = smtp_settings
  ActionMailer::Base.delivery_method = :smtp
end

if default_options.present?
    ActionMailer::Base.default_options = { from: default_options[:outgoing_address] || "Roll Call <notifications@instructure.com>" }
end
