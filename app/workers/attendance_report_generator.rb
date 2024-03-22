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
  
  def initialize(params)
    @params = params.with_indifferent_access

    check_params!
  end

  def generate
    begin
      report = AttendanceReport.new(canvas, @params)
      csv_string = report.to_csv
      filename = "attendance-#{SecureRandom.uuid}.csv"
      url = AttendanceReportUploader.s3_url(filename, csv_string)
    rescue AttendanceReport::SisFilterNotFound => e
      message = e.message
    rescue => e
      Rails.logger.error "Exception: #{e.class.name} - #{e.message}"
      notify_user_of_error(@params[:email])
      raise e
    end

    send_report(@params[:email], url, message)
  end

  def canvas
    @canvas ||= CanvasOauth::CanvasApiExtensions.build(
      @params[:canvas_url],
      @params[:user_id],
      @params[:tool_consumer_instance_guid]
    )
  end

  def send_report(email, url, message)
    ReportMailer.attendance_report(email, url, message).deliver_now
  end
  
  private
  def check_params!
    required = [:user_id, :canvas_url, :email]
    required.each do |key|
      if @params[key].blank?
        notify_user_of_error(@params[:email])
        raise "Required field #{key} is blank - unable to generate Attendance Report"
      end
    end
  end

  def notify_user_of_error(email)
    unless email.blank?
      error_message = "There was a problem generating your report. We have been notified of this issue and apologize for the inconvenience."
      ReportMailer.attendance_report(email, nil, error_message).deliver_now
    end
  end
end
