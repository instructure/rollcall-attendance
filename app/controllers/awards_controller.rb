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

class AwardsController < ApplicationController
  before_filter :can_grade

  respond_to :json

  def index
    course = load_and_authorize_course(params[:course_id])
    if course
      respond_with Award.build_list_for_student(
        course,
        params[:student_id],
        params[:class_date],
        user_id,
        tool_consumer_instance_guid
      )
    else
      not_acceptable
    end
  end

  def create
    if award_params.present? && load_and_authorize_course(award_params[:course_id])
      respond_with Award.create(award_params)
    else
      not_acceptable
    end
  end

  def destroy
    award = Award.find(params[:id])

    if award && load_and_authorize_course(award.course_id)
      award.destroy
      respond_with award
    else
      not_acceptable
    end
  end

  def stats
    if params[:course_id] && load_and_authorize_course(params[:course_id])
      respond_with Award.student_stats(
        params[:course_id],
        params[:student_id],
        tool_consumer_instance_guid
      )
    else
      not_acceptable
    end
  end

  private
  def award_params
    @award_params ||= params.require(:award).permit(:badge_id, :class_date, :student_id, :course_id).merge({
      teacher_id: user_id,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    })
  end
end
