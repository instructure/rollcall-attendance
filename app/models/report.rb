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

class Report
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  DATE_RANGE_MAX_SIZE = 6

  attr_accessor :attributes,
    :course_id,
    :canvas_url,
    :user_id,
    :account_id,
    :email,
    :start_date,
    :end_date,
    :sis_student_id,
    :sis_course_id,
    :tool_consumer_instance_guid,
    :canvas

  validates_presence_of :email
  validates_presence_of :course_id, :if => :for_course?
  validates_presence_of :account_id, :if => :for_account?
  validates_presence_of :start_date, :if => :for_account?, :unless => :has_sis_filter?
  validates_presence_of :end_date, :if => :for_account?, :unless => :has_sis_filter?
  validates_presence_of :tool_consumer_instance_guid
  validate :seven_day_date_range, :if => :for_account?, :unless => :has_sis_filter?

  def initialize(attributes = {})
    if not attributes.nil?
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end
  end

  def attributes
    attrs = {}
    [
      :course_id,
      :canvas_url,
      :user_id,
      :account_id,
      :email,
      :start_date,
      :end_date,
      :sis_student_id,
      :sis_course_id,
      :tool_consumer_instance_guid
    ].each do |attr|
      attrs[attr] = send(attr)
    end

    attrs
  end

  def type
    if for_account?
      :account
    elsif for_course?
      :course
    end
  end

  def for_course?
    course_id.present?
  end

  def for_account?
    account_id.present?
  end

  def persisted?
    false
  end

  def filters
    attributes.slice(:start_date,
                     :end_date,
                     :sis_course_id,
                     :sis_student_id)
  end

  def generate
    Resque.enqueue(AttendanceReportGenerator, report_params)
  end

  def report_params
    attrs = attributes.slice(
      :account_id,
      :course_id,
      :canvas_url,
      :email,
      :user_id,
      :tool_consumer_instance_guid
    )
    attrs[:filters] = filters
    attrs
  end

  def has_sis_filter?
    sis_course_id.present? || sis_student_id.present?
  end

  def seven_day_date_range
    if start_date.present? && end_date.present?
      days_in_range = (end_date.to_date - start_date.to_date).to_i
      if days_in_range < 0 || days_in_range > DATE_RANGE_MAX_SIZE
        errors.add(:start_date, "Start and end date must be a seven day range")
      end
    end
  end
end
