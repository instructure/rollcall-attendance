#
# Copyright (C) 2020 - present Instructure, Inc.
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

class CanvasAssignmentUpdater
  extend Resque::Plugins::Retry
  extend ResqueStats

  @queue = :canvas_assignment_updates

  # directly enqueue job when lock occurred
  @retry_delay = 0

  # we don't need the limit because at some point the lock should be cleared
  # and because we are only catching LockTimeouts
  @retry_limit = 10000

  # just catch lock timeouts
  @retry_exceptions = [Redis::Lock::LockTimeout]

  def self.retry_identifier(params)
    params = params.with_indifferent_access
    params[:identifier]
  end

  def self.perform(params)
    params = params.with_indifferent_access

    canvas = CanvasOauth::CanvasApiExtensions.build(
      params[:canvas_url],
      params[:user_id],
      params[:tool_consumer_instance_guid]
    )

    attendance_assignment = AttendanceAssignment.new(
      canvas,
      params[:course_id],
      params[:tool_launch_url],
      params[:tool_consumer_instance_guid]
    )
    canvas_assignment = attendance_assignment.fetch_or_create

    if canvas_response_has_no_errors?(canvas_assignment)
      fresh_assignment = canvas.update_assignment(
        params[:course_id],
        canvas_assignment["id"],
        params[:options]
      )

      if canvas_response_has_no_errors?(fresh_assignment)
        attendance_assignment.update_cached_assignment_if_needed(fresh_assignment)
      end
    end
  end

  protected

  def self.canvas_response_has_no_errors?(response)
    !!response && response["errors"].blank?
  end
end
