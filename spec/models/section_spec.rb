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

describe Section do
  describe "initializer" do
    subject { Section.new(id: '1', name: 'Name') }

    its(:id) { should == '1' }
    its(:name) { should == 'Name' }
    its(:students) { should == [] }

    it "creates a list of students" do
      expect(Student).to receive(:active_list_from_params).with([{name: 'John', active: true}]).and_return([{name: 'John', active: true}])
      Section.new(students: [{name: 'John', active: true}] )
    end
  end

  describe "#list_from_params" do
    subject { Section.list_from_params([
        { id: '1', name: 'Section 1' },
        { id: '2', name: 'Section 2' }
      ]) }

    its(:size) { should == 2 }
    its(:first) { should be_a Section }
  end
end
