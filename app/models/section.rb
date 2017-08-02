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

class Section
  attr_accessor :id, :name, :students, :course_id, :sis_id

  def initialize(params={})
    params.symbolize_keys!

    self.id = params[:id]
    self.name = params[:name]
    self.course_id = params[:course_id]
    self.sis_id = params[:sis_id]
    self.students = params[:students] ? Student.active_list_from_params(params[:students]) : []
  end

  def to_param
    id
  end

  def self.list_from_params(list=[])
    new_list = list.collect { |params| new(params) }
    new_list.sort_by! { |s| s.name }
  end
end
