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

config_file = File.join(Rails.root, 'config/s3.yml')
config = if File.exists?(config_file)
  erb = ERB.new(File.read(config_file)).result
  YAML.load(erb)[Rails.env].deep_symbolize_keys
else
  {
    connection: {
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      use_ssl: ENV.fetch('AWS_USE_SSL', true),
      s3_endpoint: ENV['AWS_S3_URL'],
      s3_port: ENV['AWS_S3_PORT']
    },
    bucket: ENV.fetch('AWS_BUCKET', "instructure-rollcall_#{Rails.env}"),
    prefix: ENV.fetch('AWS_PREFIX', 'attendance_reports')
  }
end

S3_BUCKET = config[:bucket]
S3_PREFIX = config[:prefix]

# docker-compose doesn't support boolean values, so :use_ssl might be a string
config[:connection][:use_ssl] = ['true', 'True', true].include?(config[:connection][:use_ssl])
# Older ruby versions have a bug that prevent URI from accepting a string for port
config[:connection][:s3_port] = config[:connection][:s3_port].try(:to_i)

if config[:connection][:access_key_id] && config[:connection][:secret_access_key]
  AWS.config config[:connection]
end
