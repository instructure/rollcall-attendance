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

class SyncAccountRelationships
  extend ResqueStats

  @queue = :sync_account_relationships

  # SyncAccountRelationships.perform({
  #   canvas_url: 'https://example.instructure.com/',
  #   user_id: 1,
  #   account_id: 2
  #   tool_consumer_instance_guid: 'blah'
  # })
  def self.perform(params)
    params = params.with_indifferent_access

    canvas = CanvasOauth::CanvasApiExtensions.build(
      params[:canvas_url],
      params[:user_id],
      params[:tool_consumer_instance_guid]
    )

    primary_canvas_account = canvas.get_account(params[:account_id])
    primary_roll_call_account = get_roll_call_account(primary_canvas_account, params[:tool_consumer_instance_guid])

    #Exit before making any more Canvas API calls if the account is fresh
    return if primary_roll_call_account.fresh?

    #reset the last_sync_on to nil in memory so that
    #build_account_associations will sync the primary_roll_call_account
    primary_roll_call_account.last_sync_on = nil

    accounts = [primary_roll_call_account]
    canvas_sub_accounts = canvas.get_account_sub_accounts(primary_roll_call_account.account_id)
    canvas_sub_accounts.each do |canvas_account|
      accounts << get_roll_call_account(canvas_account, params[:tool_consumer_instance_guid])
    end

    descendant_ids = accounts.compact.map(&:id).to_set
    primary_roll_call_account.descendants.reject { |a|
      descendant_ids.include? a.id
    }.each(&:destroy)
  end

  def self.get_roll_call_account(canvas_account, tool_consumer_instance_guid)
    account = CachedAccount.where(
      account_id: canvas_account['id'],
      tool_consumer_instance_guid: tool_consumer_instance_guid
    ).first_or_initialize

    account.parent_account_id = canvas_account['parent_account_id']
    account.save!

    account
  end
end
