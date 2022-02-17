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

class Student
  attr_accessor :id, :name, :sortable_name, :avatar_url, :sis_id, :active

  def initialize(params)
    params.symbolize_keys!

    self.id = params[:id]
    self.name = params[:name]
    self.sortable_name = params[:sortable_name]
    self.sis_id = params[:sis_id]
    self.avatar_url = params[:avatar_url]

    self.active = check_for_active_enrollments(params[:enrollments])
  end

  # Return user IDs as strings because Javascript can't handle numbers beyond
  # a certain size (which we may hit with cross-shard users)
  def as_json
    {
      id: id.to_s,
      name: name,
      sortable_name: sortable_name,
      avatar_url: avatar_url,
    }
  end

  def self.list_from_params(list=[])
    list.map{ |params| new(params) }
  end

  def self.active_list_from_params(list=[])
    list_from_params(list).select(&:active)
  end

  def check_for_active_enrollments(enrollments)
    return true if enrollments.nil?
    enrollments.any?{|e| ["active","invited"].include?(e["enrollment_state"])}
  end

  def to_h
    self
  end

end
