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

describe CachedAccount do
  before do
    @account1 = create(:cached_account)
    @account2 = create(:cached_account, parent_account_id: @account1.account_id)
    @subject  = create(:cached_account, parent_account_id: @account2.account_id)
    @account4 = create(:cached_account, parent_account_id: @subject.account_id)
    @account5 = create(:cached_account, parent_account_id: @account4.account_id)
  end

  describe "account badges" do
    before do
      @account1_badge = create(:badge, account_id: @account1.account_id, course_id: nil)
      @account2_badge = create(:badge, account_id: @account2.account_id, course_id: nil)
      @subject_badge = create(:badge, account_id: @subject.account_id, course_id: nil)
      create(:badge, account_id: @account4.account_id, course_id: nil)
      create(:badge, course_id: 123)
    end

    it "should get badges for itself and all ancestors" do
      badges = @subject.all_badges
      expect(badges.size).to eq(3)
      expect(badges).to include @account1_badge, @account2_badge, @subject_badge
    end
  end

  describe "account statuses" do
    before do
      create(:status, account_id: @account1.account_id, section_id: 1)
      @subject_status = create(:status, account_id: @subject.account_id, section_id: 2)
      @account4_status = create(:status, account_id: @account4.account_id, section_id: 3)
      @account5_status = create(:status, account_id: @account5.account_id, section_id: 4)
    end

    it "should get statuses for itself and all descendants" do
      statuses = @subject.all_statuses
      expect(statuses.size).to eq(3)
      expect(statuses).to include @subject_status, @account4_status, @account5_status
    end
  end

  describe "#fresh?" do
    it "returns false when the last sync never occurred" do
      account = CachedAccount.new
      expect(account).to_not be_fresh
    end

    it "returns false when the last sync was more than 30 minutes ago" do
      account = CachedAccount.new
      account.last_sync_on = 1.hour.ago
      expect(account).to_not be_fresh
    end

    it "returns true when the last sync was 20 minutes ago" do
      account = CachedAccount.new
      account.last_sync_on = 20.minutes.ago
      expect(account).to be_fresh
    end
  end

  describe "#refresh" do
    it "updates the last_sync_on" do
      account = create(:cached_account)
      expect do
        account.refresh
      end.to change(account, :last_sync_on)
    end
  end
end
