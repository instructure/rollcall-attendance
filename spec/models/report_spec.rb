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

describe Report do
  describe "#generate" do
    it "enqueues an Attendance Report in Resque" do
      expect(Resque).to receive(:enqueue).with(AttendanceReportGenerator, kind_of(Hash))
      Report.new.generate
    end
  end

  describe "validators" do
    it { is_expected.to validate_presence_of(:email) }

    it "does not check the date range for a course report" do
      report = Report.new(course_id: 123, start_date: 8.days.ago, end_date: Date.today)
      expect(report.errors_on(:start_date)).to be_empty
    end

    it "does not allow a date range longer than 7 days for an account report" do
      report = Report.new(account_id: 123, start_date: 8.days.ago, end_date: Date.today)
      expect(report.errors_on(:start_date)).to_not be_empty
    end

    it "does not allow an start date newer than the end date" do
      report = Report.new(account_id: 123, start_date: Date.today, end_date: 8.days.ago)
      expect(report.errors_on(:start_date)).to_not be_empty
    end

    it "does allow a date range of 0 days for an account report" do
      report = Report.new(account_id: 123, start_date: Date.today, end_date: Date.today)
      expect(report.errors_on(:start_date)).to be_empty
    end

    it "does allow a date range of 4 days for an account report" do
      report = Report.new(account_id: 123, start_date: 4.days.ago, end_date: Date.today)
      expect(report.errors_on(:start_date)).to be_empty
    end

    it "does allow a date range of 6 days for an account report" do
      report = Report.new(account_id: 123, start_date: 6.days.ago, end_date: Date.today)
      expect(report.errors_on(:start_date)).to be_empty
    end

    it "does not allow an empty start date for an account report" do
      report = Report.new(account_id: 123, start_date: "", end_date: Date.today)
      expect(report.errors_on(:start_date)).to_not be_empty
    end

    it "does not allow an empty end date for an account report" do
      report = Report.new(account_id: 123, start_date: Date.today, end_date: "")
      expect(report.errors_on(:end_date)).to_not be_empty
    end

    it "does not allow empty dates for an account report" do
      report = Report.new(account_id: 123, start_date: "", end_date: "")
      expect(report.errors_on(:start_date)).to_not be_empty
    end

    it "does not require dates if you provide a sis_course_id" do
      report = Report.new(account_id: 123, sis_course_id: 1)
      expect(report.errors_on(:start_date)).to be_empty
    end

    it "does not enforce 7 day max range if you provide a sis_course_id" do
      report = Report.new(account_id: 123, sis_course_id: 1, start_date: 8.days.ago, end_date: Date.today)
      expect(report.errors_on(:start_date)).to be_empty
    end

    it "does not require dates if you provide a sis_student_id" do
      report = Report.new(account_id: 123, sis_student_id: 1)
      expect(report.errors_on(:start_date)).to be_empty
    end

    it "does not enforce 7 day max range if you provide a sis_student_id" do
      report = Report.new(account_id: 123, sis_student_id: 1, start_date: 8.days.ago, end_date: Date.today)
      expect(report.errors_on(:start_date)).to be_empty
    end
  end
end
