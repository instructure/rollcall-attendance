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

module ReadinessCheck
  class S3
    def method
      !Aws::S3::Bucket.new(s3_config[:bucket], client: s3_client).nil?
    end

    def s3_client
      client ||= begin
        params = s3_config.slice(:access_key_id, :secret_access_key)
        params[:region] = s3_config[:region] || 'us-east-1'
        params[:endpoint] = s3_config[:endpoint] if s3_config[:endpoint]
        Aws::S3::Client.new(params)
      end
    end

    def s3_config
      config ||= begin
        config_file = File.join(Rails.root, 'config/s3.yml')
        if File.exists?(config_file)
          erb = ERB.new(File.read(config_file)).result
          conf = YAML.load(erb)[Rails.env].deep_symbolize_keys
          conf.merge(conf.delete(:connection))
        else
          {
            access_key_id: ENV['AWS_ACCESS_KEY_ID'],
            secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
            region: ENV['AWS_REGION'],
            endpoint: ENV['AWS_S3_ENDPOINT'],
            bucket: ENV.fetch('AWS_BUCKET', "instructure-rollcall_#{Rails.env}"),
            prefix: ENV.fetch('AWS_PREFIX', 'attendance_reports')
          }
        end
      end
    end
  end
end
