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

  HTTP_200 = 200.freeze
  HTTP_500 = 500.freeze
  HTTP_503 = 503.freeze

  def status_unhealthy?(status)
    return true if status == HTTP_503

    false
  end

  def components_json
    components = ReadinessCheckClass.new.add_components(
      ReadinessCheck::DbReadinessCheck::PostgreSQL.new,
      ReadinessCheck::RedisReadinessCheck::Redis.new,
      ReadinessCheck::ResqueReadinessCheck::ResqueJobs.new,
      ReadinessCheck::AwsReadinessCheck::S3.new
    )
  end

  class ReadinessCheckClass
    @components = []

    def add_component(name)
      @components.push()
    end

    def add_components(*names)
      @components = names

      check_components
    end

    def check_components
      components = []
      @components.each do |component|
        result, elapsed = with_timing{component.method}
        components.push component_check(get_name(component), result, elapsed)
      end
      @components = components
    end

    def get_components
      @components
    end

    private

    def get_name(component)
      component.class.name.split('::').last
    end

    def component_check(name, result, elapsed)
      component = {}

      component[:name] = name
      component[:status], component[:message] = status_check(result, name)
      component[:response_time_ms] = elapsed

      component
    end

    def with_timing
      start = Time.now
      begin
        result = yield
      rescue StandardError => err
        Rails.logger.error "Exception: #{err.class.name} - #{err.message}"
        result = false
      end
      [result, ((Time.now).to_f - start.to_f)*1000]
    end

    def status_check(result, name)
      return [HTTP_200, "#{name} OK"] if result

      [HTTP_503, "Cannot connect to #{name}"]
    end
  end

  def app_healthy?
    !!FileUtils.touch('/tmp')
  rescue Errno::EACCES
    false
  end
end
