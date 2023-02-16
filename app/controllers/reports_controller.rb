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

class ReportsController < ApplicationController
  include RedisCache
  include CanvasCache

  before_action :can_grade
  before_action :setup_report
  before_action :load_course_or_account
  before_action :load_user

  def new
    @report.email = @user['primary_email'] if @user

    render @report.type
  end

  def create
    if @report.valid?
      if is_cached?(report_redis_key)
        flash.now[:notice] = 'Your report is already being processed.'
      else
        cache_value(report_redis_key, 10, true)
        @report.generate
        flash.now[:notice] = 'Thank you, your report should arrive in your inbox shortly.'
      end
    else
      flash.now[:error] = 'Please double-check the marked report fields.'
    end

    render @report.type
  end

  private
  def load_course_or_account
    if @report.course_id.present?
      @course = load_and_authorize_course(@report.course_id.to_i, tool_consumer_instance_guid)
    elsif @report.account_id.present?
      # TODO: this is stupid, we should probably just be caching the data that
      # we need, or at the very least setting attributes on a CachedAccount
      # object
      if account = load_and_authorize_account(@report.account_id.to_i, tool_consumer_instance_guid)
        @canvas_account_json = get_account(account.account_id)
      end
    end

    @course || @canvas_account_json || not_acceptable
  end

  def load_user
    @user = canvas.get_user_profile(user_id)
  end

  def setup_report
    params[:report] ||= {}
    params[:report][:course_id]  ||= params[:course_id].to_i if params[:course_id].present?
    params[:report][:account_id] ||= params[:account_id].to_i if params[:account_id].present?
    params[:report][:start_date] = Chronic.parse(params[:report][:start_date]).to_date if params[:report][:start_date].present?
    params[:report][:end_date] = Chronic.parse(params[:report][:end_date]).to_date if params[:report][:end_date].present?
    params[:report][:tool_consumer_instance_guid] = tool_consumer_instance_guid
    @report = Report.new(params[:report])
    @report.canvas_url = canvas_url
    @report.user_id = user_id.to_i
  end

  def report_redis_key
    redis_cache_key(@report.tool_consumer_instance_guid,
              :report,
              @report.user_id,
              @report.email,
              @report.start_date,
              @report.end_date)
  end

  def get_account(account_id)
    key = redis_cache_key(tool_consumer_instance_guid, :account, account_id)
    request = lambda { canvas.get_account(account_id) }
    redis_cache_response key, request
  end
end
