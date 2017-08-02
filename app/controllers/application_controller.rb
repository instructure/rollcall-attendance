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

class ApplicationController < ActionController::Base
  include LtiProvider::LtiApplication
  include CanvasOauth::CanvasApplication

  include CanvasCache
  include Authorization
  include Pagination

  protect_from_forgery

  def can_admin_report
    valid_roles = [
      'urn:lti:instrole:ims/lis/Administrator', # school admin
      'urn:lti:sysrole:ims/lis/SysAdmin' # site admin
    ]
    if (valid_roles & user_roles.split(',')).blank?
      render text: "You do not have permission to launch this tool.", status: :unauthorized
    end
  end

  def can_grade
    valid_roles = [
      'urn:lti:role:ims/lis/Instructor', # course teacher
      'urn:lti:role:ims/lis/TeachingAssistant', # course ta
      'urn:lti:instrole:ims/lis/Administrator', # school admin
      'urn:lti:sysrole:ims/lis/SysAdmin' # site admin
    ]
    if (valid_roles & user_roles.split(',')).blank?
      render text: "You do not have permission to launch this tool.", status: :unauthorized
    end
  end

  def student_launch?
    user_roles.split(',').include? 'urn:lti:role:ims/lis/Learner'
  end

  def jwt_token
    unless @jwt_token
      if match = request.headers['Authorization'].try(:match, /^.+ (.+)$/)
        @jwt_token = match[1]
      end
    end
    @jwt_token
  end

  def js_env(opts = {})
    @js_env ||= {}
    @js_env.deep_merge!(opts)
    @js_env
  end
  helper_method :js_env

  def encode_jwt(hash)
    JWT.encode(hash, Rails.application.secrets.secret_key_base)
  end

  def decode_jwt(token)
    JWT.decode(token, Rails.application.secrets.secret_key_base).first.with_indifferent_access
  end

  def populate_jwt_token
    # TODO: Make this truly sessionless
    @jwt_token ||= encode_jwt({
      exp: (24.hours.from_now.to_i), # 1 day token expiration
      canvas_url: session[:canvas_url],
      course_id: session[:course_id],
      user_id: session[:user_id],
      tool_consumer_instance_guid: session[:tool_consumer_instance_guid],
      user_roles: session[:user_roles]
    })
  end

  def jwt_session
    @jwt_session ||= jwt_token ? decode_jwt(jwt_token) : {}
  end

  def session
    if jwt_session.present?
      jwt_session
    else
      super
    end
  end

  def launch_url
    lti_provider.lti_launch_url
  end
end
