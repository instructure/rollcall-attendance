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

describe AttendanceReport do
  subject(:report) { AttendanceReport.new(canvas, {account_id: @account.account_id, tool_consumer_instance_guid: 'abc123'}) }

  let(:canvas) { double }
  let(:single_api_result) do
    api_result = {
      'id' => '123',
      'sis_course_id' => 'sis_c_id',
      'course_code' => 'TECH101',
      'name' => 'Techmology 101'
    }
    allow(api_result).to receive(:not_found?).and_return(false)
    api_result
  end

  let(:multi_api_result) do
    api_result = [{
      'canvas_user_id' => '1234',
      'user_id' => 'abc123',
      'first_name' => 'Fooington',
      'last_name' => 'Barsworthy'
    }]
    allow(api_result).to receive(:not_found?).and_return(false)
    api_result
  end

  let(:account) { @account }
  let(:tci_guid) { 'abc123' }

  subject(:report) {
    AttendanceReport.new(canvas, {
      account_id: @account.account_id,
      tool_consumer_instance_guid: tci_guid
    })
  }

  before do
    @account = FactoryBot.create(:cached_account, tool_consumer_instance_guid: tci_guid)
    allow(SyncAccountRelationships).to receive_messages(perform: true)
  end

  describe "course_filter" do
    it "should cache the api response" do
      report.instance_variable_set(:@filters, sis_course_id: "sis_c_id")
      allow(canvas).to receive(:get_course).once.and_return(single_api_result)
      allow(canvas).to receive(:hex_sis_id).and_return('123')
      report.course_filter
      report.course_filter
    end
  end

  describe "student_filter" do
    it "should cache the api response" do
      report.instance_variable_set(:@filters, sis_student_id: "sis_c_id")
      allow(canvas).to receive(:get_user_profile).once.and_return(single_api_result)
      allow(canvas).to receive(:hex_sis_id).and_return('123')
      report.course_filter
      report.course_filter
    end
  end

  describe "statuses" do
    before do
      @account2 = create(:cached_account, parent_account_id: @account.account_id, tool_consumer_instance_guid: tci_guid)
      @account3 = create(:cached_account, tool_consumer_instance_guid: tci_guid)

      @status1 = create(:status, student_id: 1, course_id: 1, account_id: account.account_id, class_date: 5.days.ago, tool_consumer_instance_guid: tci_guid)
      @status2 = create(:status, student_id: 1, course_id: 2, account_id: @account2.account_id, class_date: 4.days.ago, tool_consumer_instance_guid: tci_guid)
      @status3 = create(:status, student_id: 2, course_id: 2, account_id: @account2.account_id, class_date: 3.days.ago, tool_consumer_instance_guid: tci_guid)
      @status4 = create(:status, student_id: 2, course_id: 1, account_id: account.account_id, class_date: 2.days.ago, tool_consumer_instance_guid: tci_guid)
      @status5 = create(:status, student_id: 1, course_id: 3, account_id: @account3.account_id, class_date: 1.day.ago, tool_consumer_instance_guid: tci_guid)
    end

    describe "course_ids" do
      let(:result) { report.course_ids }
      it "should get courses from the account" do
        expect(result).to include 1, 2
        expect(result).not_to include 3
      end

      it "should filter by sis_course_id" do
        allow(report).to receive(:course_filter).and_return(double(:course, id: 1))
        expect(result).to include 1
        expect(result).not_to include 2, 3
      end
    end

    describe "relevant_statuses" do
      before do
        allow(report).to receive(:course_ids) { [1, 2] }
      end
      let(:result) { report.relevant_statuses }
      describe "without date filters" do
        it "filters by the course IDs" do
          expect(result).to include @status1, @status2, @status3, @status4
          expect(result).not_to include @status5
          expect(result.size).to eq(4)
        end
      end

      describe "with date filters" do
        before do
          report.instance_variable_set(:@filters, {start_date: 4.days.ago.strftime("%m/%d/%Y"), end_date: 2.days.ago.strftime("%m/%d/%Y")})
        end
        it "filters by date" do

          expect(result).to include @status2, @status3, @status4
          expect(result).not_to include @status1, @status5
          expect(result.size).to eq(3)
        end
      end

      describe "with student filter" do
        before do
          student_double = double
          allow(student_double).to receive(:id).and_return(1)
          allow(report).to receive(:student_filter).and_return(student_double)
        end
        it "filters by student" do
          expect(result).to include @status1, @status2
          expect(result).not_to include @status3, @status4, @status5
        end
      end
    end

    describe "course with multiple sections" do
      before do
        @account4 = create(:cached_account, parent_account_id: @account.account_id, tool_consumer_instance_guid: tci_guid)

        @status6 = create(:status, student_id: 4, course_id: 4, section_id: 1, account_id: @account4.account_id, class_date: 2.days.ago, tool_consumer_instance_guid: tci_guid)
        @status7 = create(:status, student_id: 4, course_id: 4, section_id: 2, account_id: @account4.account_id, class_date: 2.days.ago, tool_consumer_instance_guid: tci_guid)
      end

      describe "a student in two sections on one day" do
        before do
          allow(report).to receive(:course_ids) { [4] }
        end
        let(:result) { report.relevant_statuses }

        it "includes separate statuses for each section" do
          expect(result).to include @status6, @status7
        end
      end
    end
  end

  describe "awards" do
    let(:account_report) { report }

    before do
      badge = create(:badge, account_id: @account.account_id, course_id: nil)
      @award1 = create(:award, student_id: 1, course_id: 1, class_date: 5.days.ago, badge_id: badge.id, tool_consumer_instance_guid: tci_guid)
      @award2 = create(:award, student_id: 1, course_id: 1, class_date: 4.days.ago, badge_id: badge.id, tool_consumer_instance_guid: tci_guid)
      @award3 = create(:award, student_id: 2, course_id: 2, class_date: 3.days.ago, badge_id: badge.id, tool_consumer_instance_guid: tci_guid)
      @award4 = create(:award, student_id: 2, course_id: 2, class_date: 2.days.ago, badge_id: badge.id, tool_consumer_instance_guid: tci_guid)
      @award5 = create(:award, student_id: 1, course_id: 3, class_date: 1.day.ago, badge_id: badge.id, tool_consumer_instance_guid: tci_guid)
    end

    describe "relevant_awards" do
      let(:result) { account_report.relevant_awards }

      before do
        allow(report).to receive(:course_ids).and_return([1, 2])
      end

      describe "for an account report" do
        it "includes awards for account-level badges" do
          expect(report.relevant_awards).to contain_exactly(@award1, @award2, @award3, @award4)
        end

        it "never includes awards for course-level badges within the account" do
          course_badge = create(:badge, account_id: @account.account_id, course_id: 1)
          course_award = create(:award, student_id: 1, course_id: 1, class_date: 3.days.ago, badge_id: course_badge.id, tool_consumer_instance_guid: tci_guid)

          expect(report.relevant_awards).not_to include(course_award)
        end
      end

      describe "for a course report" do
        let(:course_report) do
          AttendanceReport.new(canvas, {course_id: 1, account_id: @account.account_id, tool_consumer_instance_guid: tci_guid})
        end

        let(:course_api_result) do
          result = single_api_result.merge({'id' => '1'})
          allow(result).to receive(:not_found?).and_return(false)

          result
        end

        before do
          # The course needs at least one status to be included in the results
          # from AttendanceReport#course_ids
          create(:status, student_id: 1, course_id: 1, account_id: @account.account_id, class_date: 3.days.ago, tool_consumer_instance_guid: tci_guid)

          course_badge = create(:badge, account_id: @account.account_id, course_id: 1)
          @course_award = create(:award, student_id: 1, course_id: 1, class_date: 3.days.ago, badge_id: course_badge.id, tool_consumer_instance_guid: tci_guid)

          allow(canvas).to receive(:get_course).and_return(course_api_result)
        end

        it "includes relevant awards for account-level badges" do
          expect(course_report.relevant_awards).to contain_exactly(@award1, @award2)
        end

        it "never includes awards for badges defined on the course" do
          expect(course_report.relevant_awards).not_to include(@course_award)
        end
      end

      describe "no filters" do
        it "doesn't filter" do
          expect(report.relevant_awards).to contain_exactly(@award1, @award2, @award3, @award4)
        end
      end

      describe "filter by class date" do
        before do
          report.instance_variable_set(:@filters, {start_date: 4.days.ago.strftime("%m/%d/%Y"), end_date: 2.days.ago.strftime("%m/%d/%Y")})
        end
        it "filters by date" do
          expect(result).to contain_exactly(@award2, @award3, @award4)
        end
      end

      describe "filter by student id" do
        before do
          student_double = double
          allow(student_double).to receive(:id).and_return(1)
          allow(report).to receive(:student_filter).and_return(student_double)
        end

        it "filters by student" do
          expect(result).to contain_exactly(@award1, @award2)
        end
      end
    end
  end

  describe "header" do
    before do
      account = report.instance_variable_get(:@account)
    end
    it "increases the columns when adding badges" do
      allow(account).to receive(:badges).and_return([])
      report.instance_variable_set(:@account, account)
      min_length = report.header.length
      badge1 = double
      badge2 = double
      allow(badge1).to receive(:name).and_return("badge1")
      allow(badge2).to receive(:name).and_return("badge2")
      allow(account).to receive(:badges).and_return([badge1, badge2])
      expect(report.header.length).to eq(min_length + 3)
    end

    it "includes Section ID" do
      expect(report.header).to include ("Section ID")
    end

    it "includes Section Name" do
      expect(report.header).to include ("Section Name")
    end

    it "includes SIS Section ID" do
      expect(report.header).to include ("SIS Section ID")
    end

    context "when the course_filter is active" do
      before do
        report.instance_variable_set(:@filters, sis_course_id: "sis_c_id")
        allow(canvas).to receive(:get_course).once.and_return(single_api_result)
        allow(canvas).to receive(:hex_sis_id).and_return('123')
      end

      it "excludes SIS Teacher ID" do
        expect(report.header).to_not include("SIS Teacher ID")
      end

      it "excludes SIS Student ID" do
        expect(report.header).to_not include("SIS Student ID")
      end
    end
  end

  describe "#user_columns" do
    context "user is present" do
      let(:user) do
        double("User", name: "Dora", id: 1234, sis_id: 2008)
      end

      it "returns two columns with user id and user name if course_filter is present" do
        allow(report).to receive(:course_filter).and_return(Course.new)
        expect(report.user_columns(user)).to eq [user.id, user.name]
      end

      it "returns three columns with user id, user sis_id, and user name if course_filter is not present" do
        allow(report).to receive(:course_filter).and_return(nil)
        expect(report.user_columns(user)).to eq [user.id, user.sis_id, user.name]
      end
    end

    context "user is not present" do
      let(:user) { nil }

      it "returns two empty columns if user is nil but course_filter is present" do
        allow(report).to receive(:course_filter).and_return(Course.new)
        expect(report.user_columns(user)).to eq ['', '']
      end

      it "returns three empty columns if user and course_filter are nil" do
        allow(report).to receive(:course_filter).and_return(nil)
        expect(report.user_columns(user)).to eq ['', '', '']
      end
    end
  end

  context "when a course_filter is active" do
    before do
      report.instance_variable_set(:@filters, sis_course_id: "sis_c_id")
      allow(canvas).to receive(:get_course).once.and_return(single_api_result)
      allow(canvas).to receive(:hex_sis_id).and_return('123')
    end

    describe "#get_courses"  do
      it "does not hit the Reports API endpoint" do
        expect(canvas).not_to receive(:get_report)
        report.get_courses
      end
    end

    describe "#get_users"  do
      it "does not hit the Reports API endpoint" do
        report.instance_variable_set(:@filters, sis_course_id: "sis_c_id")
        allow(canvas).to receive(:get_course).once.and_return(single_api_result)
        allow(canvas).to receive(:hex_sis_id).and_return('123')
        expect(canvas).to receive(:get_all_course_users).once.and_return(multi_api_result)
        expect(canvas).not_to receive(:get_report)

        report.get_users
      end
    end

    describe "#get_teacher_enrollments"  do
      it "does not hit the Reports API endpoint" do
        report.instance_variable_set(:@filters, sis_course_id: "sis_c_id")
        allow(canvas).to receive(:get_course).once.and_return(single_api_result)
        allow(canvas).to receive(:hex_sis_id).and_return('123')
        expect(canvas).to receive(:get_course_teachers_and_tas).once.and_return(multi_api_result)
        expect(canvas).not_to receive(:get_report)

        report.get_teacher_enrollments
      end
    end
  end

  describe '#get_courses' do
    it "adds 'include_delete' to queries" do
      expect(canvas).to receive(:get_report).with(
        any_args,
        {
          "parameters[courses]" => true,
          "parameters[include_deleted]" => true
        }
      ).and_return([])
      report.get_courses
    end
  end

  describe 'Correct formation of Section Columns in report #section_columns' do
    context 'when section id is null' do
      let(:section_id) { nil }
      before do
        @columns = report.section_columns(section_id)
      end

      it "returns an empty array" do
        expect(@columns).to eq(Array.new(3) {''})
      end

      it "does not call canvas api for section information" do
        expect(report).not_to receive(:get_section)
      end
    end

    context 'when section id is not null' do
      let(:section_id) { 1 }
      before do
        allow(report).to receive(:get_section).and_return({"name" => "Test", "sis_section_id" => ""})
      end

      it "returns the section information" do
        @columns = report.section_columns(section_id)
        expect(@columns).to eq(['Test', 1, ''])
      end
    end
  end

  describe "Check if section infotmation is cached #get_section" do
    let(:redis) { $REDIS }
    let(:section_id) { 1 }

    it "does not call the canvas api if chached" do
      allow(redis).to receive(:get).and_return('{"name" : "Test", "sis_section_id" : ""}')
      expect(canvas).not_to receive(:get_section)
      report.get_section(section_id)
    end
  end
end
