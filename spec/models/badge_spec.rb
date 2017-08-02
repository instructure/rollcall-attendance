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

describe Badge do
  subject { build_stubbed(:badge) }

  describe "validations" do
    it { is_expected.to be_valid }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :icon }
    it { is_expected.to validate_presence_of :color }

    it  "won't allow empty course_id and account_id" do
      badge = FactoryGirl.build(:badge)
      badge.course_id = nil
      badge.account_id = nil
      badge.valid?
      expect(badge.errors[:id]).to include 'A badge must have either a course or an account'
    end

    it  "will allow only a course_id and not a account_id" do
      badge = FactoryGirl.build(:badge)
      badge.course_id = 1
      badge.account_id = nil
      badge.valid?
      expect(badge.errors[:id]).not_to include 'A badge must have either a course or an account'
    end

    it  "will allow no course_id and only a account_id" do
      badge = FactoryGirl.build(:badge)
      badge.course_id = nil
      badge.account_id = 1
      badge.valid?
      expect(badge.errors[:id]).not_to include 'A badge must have either a course or an account'
    end



  end
end
