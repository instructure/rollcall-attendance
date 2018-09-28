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

describe Student do
  let(:student) { Student.new(id: 1) }

  describe "initializer" do
    subject { Student.new(id: '1', name: 'Name', avatar_url: 'avatar') }

    its(:id) { should == '1' }
    its(:name) { should == 'Name' }
    its(:avatar_url) { should == 'avatar' }
  end

  describe "#list_from_params" do
    subject { Student.list_from_params([
        { id: '1', name: 'Student 1', avatar_url: 'avatar1' },
        { id: '2', name: 'Student 2', avatar_url: 'avatar2' }
      ]) }

    its(:size) { should == 2 }
    its(:first) { should be_a Student }
    its('first.avatar_url') { should == 'avatar1' }
  end

  describe "#as_json" do
    it "returns the id as a string" do
      student = Student.new(id: 123, name: 'Fred')

      expect(student.as_json[:id]).to eq '123'
    end
  end
end
