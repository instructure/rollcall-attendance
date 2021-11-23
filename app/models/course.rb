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

class Course
  attr_accessor :id, :account_id, :root_account_id, :sis_id, :course_code, :name

  def initialize(params={})
    params.symbolize_keys!

    self.id = params[:id]
    self.account_id = params[:account_id]
    self.root_account_id = params[:root_account_id]
    self.sis_id = params[:sis_id]
    self.course_code = params[:course_code]
    self.name = params[:name]
  end
end
