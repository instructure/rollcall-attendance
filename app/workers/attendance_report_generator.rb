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

class AttendanceReportGenerator
  class S3StorageFailure < StandardError;end

  @queue = :attendance_reports

  def self.perform(params)
    params = params.with_indifferent_access

    check_params!(params)

    begin
      canvas = CanvasOauth::CanvasApiExtensions.build(
        params[:canvas_url],
        params[:user_id],
        params[:tool_consumer_instance_guid]
      )
      report = AttendanceReport.new(canvas, params)
      csv_string = report.to_csv
      filename = "attendance-#{SecureRandom.uuid}.csv"
      url = s3_url(filename, csv_string)
    rescue AttendanceReport::SisFilterNotFound => e
      message = e.message
    rescue => e
      Rails.logger.error "Exception: #{e.class.name} - #{e.message}"
      notify_user_of_error(params[:email])
      raise e
    end

    ReportMailer.attendance_report(params[:email], url, message).deliver_now
  end

  def self.s3_url(filename, data, expires_in = 24.hours)
    expires = expires_in.from_now

    filename = "#{S3_PREFIX}/#{filename}" if S3_PREFIX.present?
    s3_file = AWS::S3.new.buckets[S3_BUCKET].objects[filename].write(data, content_type: 'text/csv', content_disposition: "attachment;filename=#{filename}")

    if s3_file.exists?
      s3_file.url_for(:read, expires: expires).to_s
    else
      raise AttendanceReportGenerator::S3StorageFailure
    end
  end

  def self.check_params!(params)
    required = [:user_id, :canvas_url, :email]
    required.each do |key|
      if params[key].blank?
        notify_user_of_error(params[:email])
        raise "Required field #{key} is blank - unable to generate Attendance Report"
      end
    end
  end

  def self.notify_user_of_error(email)
    unless email.blank?
      error_message = "There was a problem generating your report. We have been notified of this issue and apologize for the inconvenience."
      ReportMailer.attendance_report(email, nil, error_message).deliver_now
    end
  end
end
