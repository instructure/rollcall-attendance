#
# Copyright (C) 2019 - present Instructure, Inc.
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

module DataFixup::BackfillNulls
  def self.run(klass, field, new_value:, batch_size: 1000)
    objects_to_backfill = klass.where(field => nil)
    objects_to_backfill.in_batches(of: batch_size).update_all(field => new_value, updated_at: Time.zone.now)
  end
end
