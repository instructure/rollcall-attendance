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
  UPDATE_N_STRAND = /^CanvasAssignmentUpdater#update::.*::.*$/

  def initialize(params)
    @params = params
  end

  def update
    params = @params.with_indifferent_access

    begin
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
    rescue => e
      msg = "Exception updating assignment: #{e.to_s} \nwith params:#{params.to_s}"
      Rails.logger.error msg
      raise
    end
  end

  def enqueue!
    self.delay(n_strand: strand_name, max_attempts: 5).update
  end

  private

  def strand_name
    "CanvasAssignmentUpdater#update::#{@params[:tool_consumer_instance_guid]}::#{@params[:course_id]}"
  end

  protected

  def canvas_response_has_no_errors?(response)
    !!response && response["errors"].blank?
  end
end
