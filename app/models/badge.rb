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

class Badge < ActiveRecord::Base
  validates :color, :icon, :name, :tool_consumer_instance_guid, presence: true
  validate :course_or_account_id

  has_many :awards, dependent: :destroy

  def course_or_account_id
    unless self.course_id || self.account_id
      errors.add(:id, 'A badge must have either a course or an account')
    end
  end
end
