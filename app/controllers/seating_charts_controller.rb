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

class SeatingChartsController < ApplicationController
  before_action :can_grade

  respond_to :json

  def create
    if load_and_authorize_course(seating_chart_params[:course_id])
      chart = SeatingChart.where({
        section_id: seating_chart_params[:section_id],
        class_date: seating_chart_params[:class_date],
        tool_consumer_instance_guid: tool_consumer_instance_guid
      }).first
      chart ||= SeatingChart.new

      chart.attributes = seating_chart_params
      chart.save
      respond_with chart
    else
      not_acceptable
    end
  end

  private
  def seating_chart_params
    @seating_chart_params ||= params.require(:seating_chart).permit(:class_date, :course_id, :section_id, assignments: [:row, :col]).merge({
      tool_consumer_instance_guid: tool_consumer_instance_guid
    })
  end
end
