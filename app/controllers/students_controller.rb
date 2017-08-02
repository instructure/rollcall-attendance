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

class StudentsController < ApplicationController
  before_action :populate_jwt_token, only: [:show]
  before_action :authorize_student

  def show
    js_env jwt_token: jwt_token, course_id: params[:course_id], student_id: params[:id]
  end

  private
  def authorize_student
    load_and_authorize_student(params[:course_id], params[:id])
  end
end
