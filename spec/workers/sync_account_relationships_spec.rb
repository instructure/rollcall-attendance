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
  describe "perform" do
    let(:user_id) { 1 }
    let(:account_id) { 2 }
    let(:canvas_url) { 'http://test.canvas' }
    let(:tool_consumer_instance_guid) { 'abc123' }
    let(:canvas) {double(:canvas_api)}

    let(:valid_params) {
      {
        'canvas_url' => canvas_url,
        'user_id' => user_id,
        'account_id' => account_id,
        'tool_consumer_instance_guid' => tool_consumer_instance_guid
      }
    }

    describe "get account" do
      before do
        @account1 = create(:cached_account)
        @account2 = create(:cached_account)

        allow(canvas).to receive(:get_account) do |account_id|
          result = {'id' => account_id, 'parent_account_id' => @account1.account_id}
          allow(result).to receive(:not_found?).and_return(false)
          result
        end
      end

      it "finds and updates existing accounts" do
        result = {'id' => @account2.account_id, 'parent_account_id' => @account1.account_id}
        account = SyncAccountRelationships.get_roll_call_account(result, tool_consumer_instance_guid)
        expect(account.account_id).to eq(@account2.account_id)
        expect(account.parent.account_id).to eq(@account1.account_id)

        ar_account = CachedAccount.find_by_account_id(@account2.account_id)
        expect(ar_account.account_id).to eq(account.account_id)
        expect(ar_account.parent.account_id).to eq(account.parent.account_id)
      end

      it "builds new accounts from the api" do
        @account3 = create(:cached_account)
        @account3.destroy

        expect(CachedAccount.exists?(@account3.id)).to eq(false)
        result = {'id' => @account3.account_id, 'parent_account_id' => @account1.account_id}
        account = SyncAccountRelationships.get_roll_call_account(result, tool_consumer_instance_guid)
        expect(account.account_id).to eq(@account3.account_id)
        expect(account.parent.account_id).to eq(@account1.account_id)
        expect(CachedAccount.where(
          account_id: @account3.account_id,
          tool_consumer_instance_guid: tool_consumer_instance_guid
        ).first).not_to be_nil
      end
    end

    describe "build account associations" do
      before do
        @account1 = create(:cached_account)
        @account2 = create(:cached_account, parent_account_id: @account1.account_id)
        @account3 = create(:cached_account, parent_account_id: @account2.account_id)
        @accounts = [@account1, @account2, @account3]
      end

      it "finds all descendants of a root account" do
        expect(SyncAccountRelationships).to receive(:find_descendants).and_yield(@account2).and_yield(@account3)
        SyncAccountRelationships.find_descendants(@account1.id, @accounts) {|account|}
      end

      it "finds all descendants of a sub-account" do
        expect(SyncAccountRelationships).to receive(:find_descendants).and_yield(@account3)
        SyncAccountRelationships.find_descendants(@account2.id, @accounts) {|account|}
      end

      it "creates associations for all descendants" do
        expect(@account1.descendants).to include @account2, @account3
      end
    end
  end
end
