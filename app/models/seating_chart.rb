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

class SeatingChart < ApplicationRecord
  validates :class_date, :course_id, :section_id, :tool_consumer_instance_guid, presence: true

  serialize :assignments, Hash

  def assignments= hash
    # Assignments recieves a hash of parameter hashes, when serialized it should
    # be a hash of hashes
    super Hash[hash.map{|k,v| [k,v.to_hash]}]
  end

  def assignment(student_id)
    assignments[student_id.to_s]
  end

  def self.latest(class_date, section_id, tool_consumer_instance_guid, course_id)
    where({
      section_id: section_id,
      tool_consumer_instance_guid: tool_consumer_instance_guid,
      course_id: course_id
    }).where("class_date <= ?", class_date).order("class_date DESC").first
  end
end
