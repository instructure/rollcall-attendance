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

class BadgesController < ApplicationController
  before_action :can_grade

  respond_to :json

  def index
    if course = load_and_authorize_course(params[:course_id], tool_consumer_instance_guid)
      respond_with Badge.where({
        course_id: course.id,
        tool_consumer_instance_guid: tool_consumer_instance_guid
      }).order(:name)
    elsif account = load_and_authorize_account(params[:account_id], tool_consumer_instance_guid)
      respond_with account.badges
    else
      head :not_acceptable
    end
  end

  def create
    if params[:badge] &&
        (load_and_authorize_course(params[:badge][:course_id], tool_consumer_instance_guid) ||
         load_and_authorize_account(params[:badge][:account_id], tool_consumer_instance_guid)
        )
      badge = Badge.create(create_badge_params)
      respond_with badge
    else
      head :not_acceptable
    end
  end

  def update
    badge = Badge.find(params[:id])
    if badge &&
        (load_and_authorize_course(badge.course_id, tool_consumer_instance_guid) ||
         load_and_authorize_account(badge.account_id, tool_consumer_instance_guid)
        )
      badge.update(update_badge_params)
      respond_with badge
    else
      head :not_acceptable
    end
  end

  def destroy
    badge = Badge.find(params[:id])

    if badge &&
        (load_and_authorize_course(badge.course_id, tool_consumer_instance_guid) ||
         load_and_authorize_account(badge.account_id, tool_consumer_instance_guid)
        )
      badge.destroy
      respond_with badge
    else
      head :not_acceptable
    end
  end

  private
  def create_badge_params
    params.require(:badge).permit(
      :color,
      :icon,
      :name,
      :course_id,
      :account_id
    ).merge({
      tool_consumer_instance_guid: tool_consumer_instance_guid
    })
  end

  def update_badge_params
    params.require(:badge).permit(
      :color,
      :icon,
      :name
    )
  end
end
