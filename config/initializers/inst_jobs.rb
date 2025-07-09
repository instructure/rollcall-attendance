#
# Copyright (C) 2025 - present Instructure, Inc.
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

require 'delayed/server'
require 'raven/integrations/delayed_job'

module Initializers
  class InstJobs

    def initialize
      # Cap the maximum number of concurrent jobs of a given strand to prevent
      # one particular set of jobs monopolizing too many job workers
      Delayed::Settings.num_strands = proc do |strand_name|
        case strand_name
        # GradeUpdater and AllGradeUpdater have the same strand name
        when GradeUpdater::SUBMIT_GRADE_N_STRAND
          1
        when AllGradeUpdater::SUBMIT_GRADES_N_STRAND
          1
        when CanvasAssignmentUpdater::UPDATE_N_STRAND
          1
        when SyncAccountRelationships::SYNC_N_STRAND
          1
        else
          1
        end
      end

      # Returns a boolean value to determine if the job should be kept
      # true: job will be destroyed
      # false: last_error will be set and job is moved to the failed_jobs table
      Delayed::Worker.on_max_failures = proc do |_job, err|
        # We don't want to keep around max_attempts failed jobs that failed because the
        # underlying AR object was destroyed.
        # All other failures are kept for inspection.
        err.is_a?(Delayed::Backend::RecordNotFound)
      end
    end
  end
end
