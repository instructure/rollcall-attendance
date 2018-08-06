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

require 'spec_helper'

describe SyncAccountRelationships do
  let(:user_id) { '1' }
  let(:account_id) { '2' }
  let(:canvas_url) { 'http://test.canvas' }
  let(:tool_consumer_instance_guid) { 'abc123' }
  let(:canvas) {double(:canvas_api)}

  let(:valid_params) {
    {
      canvas_url: canvas_url,
      user_id: user_id,
      account_id: account_id,
      tool_consumer_instance_guid: tool_consumer_instance_guid
    }
  }

  describe "#perform" do
    before :each do
      @account1 = create(:cached_account)
      @account2 = create(:cached_account)
      @account3 = create(:cached_account)

      allow(CanvasOauth::CanvasApiExtensions).to receive(:build).and_return(canvas)
      allow(canvas).to receive(:get_account).and_return({})
    end

    it "updates accounts with parent account id" do
      allow(canvas).to receive(:get_account_sub_accounts).and_return([])
      allow(canvas).to receive(:get_account) do |account_id|
        result = {'id' => account_id, 'parent_account_id' => @account1.account_id}
        allow(result).to receive(:not_found?).and_return(false)
        result
      end

      valid_params[:account_id] = @account2.account_id
      SyncAccountRelationships.perform(valid_params)
      cached_account = CachedAccount.where(
        account_id: @account2.account_id,
        tool_consumer_instance_guid: tool_consumer_instance_guid
      ).first

      expect(cached_account.parent.account_id).to eq(@account1.account_id)
    end

    it "finds all descendants of a root account" do
      @account2.update!(parent_account_id: @account1.account_id)
      @account3.update!(parent_account_id: @account1.account_id)

      allow(canvas).to receive(:get_account_sub_accounts).and_return(
        [
          { 'id' => @account2.account_id, 'parent_account_id' => @account1.account_id },
          { 'id' => @account3.account_id, 'parent_account_id' => @account1.account_id },
        ]
      )

      valid_params[:account_id] = @account1.account_id
      SyncAccountRelationships.perform(valid_params)

      expect(@account1.descendants).to include @account2, @account3
    end

    it "finds all descendants of sub-accounts too" do
      @account2.update!(parent_account_id: @account1.account_id)
      @account3.update!(parent_account_id: @account2.account_id)

      allow(canvas).to receive(:get_account_sub_accounts).and_return(
        [
          { 'id' => @account2.account_id, 'parent_account_id' => @account1.account_id },
          { 'id' => @account3.account_id, 'parent_account_id' => @account2.account_id },
        ]
      )

      valid_params[:account_id] = @account1.account_id
      SyncAccountRelationships.perform(valid_params)

      expect(@account1.descendants).to contain_exactly(@account2, @account3)
    end

    it "creates associations for all descendants" do
      @account2.update!(parent_account_id: @account1.account_id)
      @account3.update!(parent_account_id: @account2.account_id)
      expect(@account1.descendants).to contain_exactly(@account2, @account3)
    end

    it "does not ask for canvas subaccounts if recently run" do
      allow(canvas).to receive(:get_account_sub_accounts).and_return([])
      expect(canvas).to receive(:get_account_sub_accounts).once
      SyncAccountRelationships.perform(valid_params)
      SyncAccountRelationships.perform(valid_params)
    end

    it "asks for canvas subaccounts if not recently run" do
      allow(canvas).to receive(:get_account_sub_accounts).and_return([])
      expect(canvas).to receive(:get_account_sub_accounts).twice

      SyncAccountRelationships.perform(valid_params)
      SyncAccountRelationships.get_roll_call_account(
        canvas_account_id: valid_params[:account_id],
        tool_consumer_instance_guid: valid_params[:tool_consumer_instance_guid]
      ).update!(last_sync_on: 6.minutes.ago)
      SyncAccountRelationships.perform(valid_params)
    end
  end

  describe "#get_roll_call_accounts" do
    before :each do
      @account1 = create(:cached_account)
      @account2 = create(:cached_account)
    end

    it "finds existing accounts" do
      account = SyncAccountRelationships.get_roll_call_account(
        canvas_account_id: @account1.account_id,
        tool_consumer_instance_guid: tool_consumer_instance_guid
      )
      ar_account = CachedAccount.find_by_account_id(@account1.account_id)

      expect(account.account_id).to eq(@account1.account_id)
      expect(ar_account.account_id).to eq(account.account_id)
    end

    it "builds new accounts if not already existing" do
      @account2 = create(:cached_account)
      @account2.destroy!

      expect(CachedAccount.exists?(@account2.id)).to eq(false)
      account = SyncAccountRelationships.get_roll_call_account(
        canvas_account_id: @account2.account_id,
        tool_consumer_instance_guid: tool_consumer_instance_guid
      )
      account.save!
      cached_account = CachedAccount.where(
        account_id: @account2.account_id,
        tool_consumer_instance_guid: tool_consumer_instance_guid
      ).first

      expect(account.account_id).to eq(@account2.account_id)
      expect(cached_account).not_to be_nil
    end
  end
end
