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
  SYNC_N_STRAND = /^SyncAccountRelationships#sync::.*::.*$/
  SYNC_SINGLETON = /^SyncAccountRelationships#sync::.*::.*$/

  def initialize(params)
    @params = params.with_indifferent_access
  end

  def sync
    primary_roll_call_account = get_roll_call_account(
      canvas_account_id: @params[:account_id],
      tool_consumer_instance_guid: @params[:tool_consumer_instance_guid]
    )

    # exit before making any more Canvas API calls if the account is fresh
    return if primary_roll_call_account.fresh?

    canvas = CanvasOauth::CanvasApiExtensions.build(
      @params[:canvas_url],
      @params[:user_id],
      @params[:tool_consumer_instance_guid]
    )

    primary_canvas_account = canvas.get_account(@params[:account_id])
    primary_roll_call_account.parent_account_id = primary_canvas_account['parent_account_id']
    primary_roll_call_account.save!

    accounts = [primary_roll_call_account]
    canvas_sub_accounts = canvas.get_account_sub_accounts(primary_roll_call_account.account_id)
    primary_roll_call_account.refresh

    canvas_sub_accounts.each do |canvas_account|
      accounts << get_roll_call_account(
        canvas_account_id: canvas_account['id'],
        parent_account_id: canvas_account['parent_account_id'],
        tool_consumer_instance_guid: @params[:tool_consumer_instance_guid]
      )
    end

    descendant_ids = accounts.compact.map(&:id).to_set

    primary_roll_call_account.descendants.reject { |a|
      descendant_ids.include? a.id
    }.each(&:destroy)
  end

  def get_roll_call_account(canvas_account_id:, parent_account_id: nil, tool_consumer_instance_guid:)
    account = CachedAccount.where(
      account_id: canvas_account_id,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    ).first_or_initialize
    account.parent_account_id = parent_account_id if parent_account_id
    account.save!

    account
  end

  def enqueue!
    self.delay(n_strand: strand_name, singleton: singleton_name).sync
  end

  private

  def strand_name
    "SyncAccountRelationships#sync::#{@params[:tool_consumer_instance_guid]}::#{@params[:account_id]}"
  end

  def singleton_name
    "SyncAccountRelationships#sync::#{@params[:tool_consumer_instance_guid]}::#{@params[:account_id]}"
  end

end
