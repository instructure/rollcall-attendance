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

class Award < ApplicationRecord
  validates :badge_id, :class_date, :student_id, :teacher_id, :course_id, :tool_consumer_instance_guid, presence: true

  belongs_to :badge

  def self.build_list_for_student(course, student_id, class_date, teacher_id, tool_consumer_instance_guid)
    awards = Award.where({
      course_id: course.id,
      student_id: student_id,
      class_date: class_date,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    }).to_a
    awarded_badges = awards.map(&:badge_id)

    account = CachedAccount.where(
      account_id: course.account_id,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    ).first_or_create

    badges = Badge.where({
      course_id: course.id,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    }).order(:name)
    badges |= account.all_badges

    badges.each do |badge|
      unless awarded_badges.include?(badge.id)
        award = Award.new({
          class_date: class_date,
          student_id: student_id,
          course_id: course.id,
          teacher_id: teacher_id,
          tool_consumer_instance_guid: tool_consumer_instance_guid
        })
        award.badge = badge
        awards << award
      end
    end

    return awards.sort_by { |award| award.badge.name }
  end

  def self.student_stats(course_id, student_id, tool_consumer_instance_guid)
    counts = Award.where({
      course_id: course_id,
      student_id: student_id,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    }).group(:badge_id).count
    stats = {}

    Badge.where({
      course_id: course_id,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    }).find_each do |badge|
      stats[badge.name] = counts[badge.id] || 0
    end

    Hash[stats.sort]
  end

  # Return user IDs as strings because Javascript can't handle numbers beyond
  # a certain size (which we may hit with cross-shard users)
  def as_json(options={})
    {
      id: id,
      student_id: student_id.to_s,
      teacher_id: teacher_id.to_s,
      course_id: course_id,
      class_date: class_date,
      badge_id: badge_id,
      badge: badge
    }
  end
end
