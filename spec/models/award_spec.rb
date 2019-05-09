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

describe Award do

  subject(:award) { build_stubbed(:award) }

  describe "validations" do
    it { is_expected.to be_valid }

    it { is_expected.to validate_presence_of :student_id }
    it { is_expected.to validate_presence_of :teacher_id }
    it { is_expected.to validate_presence_of :badge_id }
    it { is_expected.to validate_presence_of :class_date }
    it { is_expected.to validate_presence_of :course_id }
  end

  describe "as_json" do
    let(:badge) { Badge.new }

    before { award.badge = badge }

    it "includes the badge" do
      expect(award.as_json[:badge]).to eq(badge)
    end

    it "returns the student_id as a string" do
      award.student_id = 567
      expect(award.as_json[:student_id]).to eq '567'
    end

    it "returns the student_id as a string" do
      award.teacher_id = 456
      expect(award.as_json[:teacher_id]).to eq '456'
    end
  end

  describe "#build_list_for_student" do
    let(:course_id) { 1 }
    let(:student_id) { 2 }
    let(:teacher_id) { 5 }
    let(:class_date) { Time.now.utc.to_date }
    let(:tool_consumer_instance_guid) { "abc123" }

    subject do
      Award.build_list_for_student(@double_course, student_id, class_date, teacher_id, tool_consumer_instance_guid)
    end

    before do
      @double_course = double(:course, :id => 1, :account_id => 1)

      @badge1 = Badge.create!(course_id: course_id, name: 'Participation', icon: '+', color: 'red', tool_consumer_instance_guid: tool_consumer_instance_guid)
      @badge2 = Badge.create!(course_id: course_id, name: 'Good Citizen', icon: '!', color: 'blue', tool_consumer_instance_guid: tool_consumer_instance_guid)
      @badge3 = Badge.create!(course_id: 2, name: 'Participation', icon: '+', color: 'red', tool_consumer_instance_guid: tool_consumer_instance_guid)
      @badge4 = Badge.create!(account_id: @double_course.account_id, name: 'Participation', icon: '+', color: 'red', tool_consumer_instance_guid: tool_consumer_instance_guid)
    end

    context "when the student has no awards" do
      its(:size) { should == 3 }
      specify { expect(subject.all?(&:new_record?)).to be_truthy }
    end

    context "when the student has awards" do
      before { create(:award, course_id: course_id, student_id: student_id, class_date: class_date, badge_id: @badge1.id, tool_consumer_instance_guid: tool_consumer_instance_guid) }

      its(:size) { should == 3 }
      specify { expect(subject.all?(&:new_record?)).to be_falsey }
      specify { expect(subject.map(&:badge)).to include @badge1, @badge2, @badge4 }

      it "is not teacher specific" do
        awards = Award.build_list_for_student(@double_course, student_id, class_date, teacher_id + 1, tool_consumer_instance_guid)
        expect(awards.all?(&:new_record?)).to be false
      end
    end
  end

  describe "student_stats" do
    let(:student_id) { 1 }
    let(:course_id) { 2 }
    let(:other_course_id) { 3 }
    let(:tool_consumer_instance_guid) { "abc123" }

    subject(:stats) { Award.student_stats(course_id, student_id, tool_consumer_instance_guid) }

    context "with awards" do
      before do
        @participation = create(:badge, course_id: course_id, name: 'Participation', icon: '+', color: 'red', tool_consumer_instance_guid: tool_consumer_instance_guid)
        @good_citizen = create(:badge, course_id: course_id, name: 'Good Citizen', icon: '!', color: 'blue', tool_consumer_instance_guid: tool_consumer_instance_guid)
        @participation_other_course = create(:badge, course_id: other_course_id, name: 'Participation', icon: '+', color: 'red', tool_consumer_instance_guid: tool_consumer_instance_guid)

        create(:award, badge_id: @participation.id, student_id: student_id, class_date: 3.weeks.ago, course_id: course_id, tool_consumer_instance_guid: tool_consumer_instance_guid)
        create(:award, badge_id: @participation.id, student_id: student_id, class_date: 2.weeks.ago, course_id: course_id, tool_consumer_instance_guid: tool_consumer_instance_guid)

        create(:award, badge_id: @good_citizen.id, student_id: student_id, class_date: 2.weeks.ago, course_id: course_id, tool_consumer_instance_guid: tool_consumer_instance_guid)

        create(:award, badge_id: @participation_other_course.id, student_id: student_id, class_date: 3.weeks.ago, course_id: other_course_id, tool_consumer_instance_guid: tool_consumer_instance_guid)
      end

      it { is_expected.to eq({ 'Good Citizen' => 1, 'Participation' => 2 }) }
    end

    context "with no awards" do
      it { is_expected.to eq({}) }
    end
  end
end
