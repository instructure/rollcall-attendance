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

class CachedAccount < ActiveRecord::Base
  SYNC_TTL=30.minutes

  validates :account_id, presence: true

  def parent
    CachedAccount.where(
      account_id: parent_account_id,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    ).first
  end

  def children
    CachedAccount.where(
      parent_account_id: account_id,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    )
  end

  def badges
    Badge.where(
      account_id: account_id,
      course_id: nil,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    )
  end

  def statuses
    Status.where(
      account_id: account_id,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    )
  end

  # TODO: make this good when we switch to postgres
  def ancestors
    previous_generation = parent
    predecessors = []
    while previous_generation != nil
      predecessors << previous_generation
      previous_generation = previous_generation.parent

      # prevent cached account loop from turning into infinite while loop
      break if predecessors.include?(previous_generation)
    end
    predecessors
  end

  def ancestor_badges
    Badge.where(
      account_id: ancestors.map(&:account_id),
      course_id: nil,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    )
  end

  # TODO: make this good when we switch to postgres
  def descendants(next_generation = children, offspring = [])
    if next_generation.empty?
      offspring
    else
      descendants(next_generation.flat_map(&:children) - offspring,
                  offspring + next_generation)
    end
  end

  def descendant_statuses
    Status.where(
      account_id: descendants.map(&:account_id),
      tool_consumer_instance_guid: tool_consumer_instance_guid
    )
  end

  def all_badges
    self.ancestor_badges | self.badges
  end

  def all_statuses
    self.descendant_statuses | self.statuses
  end

  def fresh?
    last_sync_on.present? && last_sync_on > SYNC_TTL.ago
  end

  def refresh
    update_attribute(:last_sync_on, Time.now)
  end
end
