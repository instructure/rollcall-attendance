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
require 'health_check'

describe HealthCheck do

  describe "healthy?" do
    it "is healthy when nothing is wrong" do
      expect(HealthCheck.new.healthy?).to be true
    end

    it "is false when you can't talk to the database" do
      allow(ActiveRecord::Base.connection).to receive(:select_value).and_raise(StandardError)
      expect(HealthCheck.new.healthy?).to be false
      # allow the test transaction to do it's thing
      allow(ActiveRecord::Base.connection).to receive(:select_value).and_call_original
    end

    it "is false when you can't access the file system" do
      allow(FileUtils).to receive(:touch).and_raise(Errno::EACCES)
      expect(HealthCheck.new.healthy?).to be false
    end
  end

end
