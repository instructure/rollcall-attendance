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

class CourseTardyWeight
  def self.for(course_id, tool_consumer_instance_guid)
    cc = CourseConfig.where(
      course_id: course_id,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    ).first
    cc.try(:tardy_weight) || default_tardy_weight
  end

  def self.default_tardy_weight
    0.8
  end
end
