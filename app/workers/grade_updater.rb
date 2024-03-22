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

class GradeUpdater

  def initialize(params)
    @params = params
  end

  def submit_grade
    params = @params.with_indifferent_access
    begin
      canvas = CanvasOauth::CanvasApiExtensions.build(
        params[:canvas_url],
        params[:user_id],
        params[:tool_consumer_instance_guid]
      )

      assignment = AttendanceAssignment.new(canvas, params[:course_id], params[:tool_launch_url], params[:tool_consumer_instance_guid])
      canvas_assignment = assignment.fetch_or_create

      # TODO: once we're sure that we found root cause for beating up canvas, we can remove this whole lock strategy
      lock_key = "grade_updater.guid_#{params[:tool_consumer_instance_guid]}" \
        ".assignment_id_#{canvas_assignment['id']}" \
        ".student_id_#{params[:student_id]}"

      begin
        lock_manager = Redlock::Client.new([redis.id], retry_count: 0)
        lock_manager.lock!(lock_key, 60) do |locked|
          # expiration and timeout are in seconds
            assignment.submit_grade(
              canvas_assignment['id'],
              params[:student_id]
            )
        end
      rescue Redlock::LockError => e
        # We're swallowing the lock error here as its ok, we'll assume the thing that has this lock is doing its job.
        Rails.logger.error ("Failed to acquire lock for #{lock_key} with params:#{params.to_s}")
      end
    rescue => e
      msg = "Exception submitting grade: #{e.to_s} with params:#{params.to_s}"
      Rails.logger.error msg
      raise
    end
  end
  
  private
  
  def redis
    $REDIS
  end
end
