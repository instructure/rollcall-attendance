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

class AllGradeUpdater
  def initialize(params)
    @params = params
  end

  def submit_grades
    params = @params.with_indifferent_access
    begin
      canvas = CanvasOauth::CanvasApiExtensions.build(
        params[:canvas_url],
        params[:user_id],
        params[:tool_consumer_instance_guid]
      )

      assignment = AttendanceAssignment.new(canvas, params[:course_id], params[:tool_launch_url], params[:tool_consumer_instance_guid])
      if canvas_assignment = assignment.fetch_or_create
        assignment.submit_grades(canvas_assignment['id'], params[:student_ids])
      end
    rescue => e
      msg = "Exception submitting grades: #{e.to_s} with params:#{params.to_s}"
      Rails.logger.error msg
      raise
    end
  end
end
