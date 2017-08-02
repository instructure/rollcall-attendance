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

class AttendanceCollection
  def initialize
    @attendance_records = {}
  end

  def add_status(status)
    attendance = Attendance.new(status: status)

    if @attendance_records.has_key? attendance
      @attendance_records[attendance].status = status
    else
      @attendance_records[attendance] = attendance
    end
  end

  def add_award(award)
    attendance = Attendance.new(award: award)

    if @attendance_records.has_key? attendance
      @attendance_records[attendance].add_award award
    else
      @attendance_records[attendance] = attendance
    end
  end

  def each(&block)
    @attendance_records.values.each(&block)
  end

  def size
    @attendance_records.size
  end

end
