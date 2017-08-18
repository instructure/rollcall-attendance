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

module Pagination

  def pagination_params
    opts = params.to_unsafe_h.slice(:page, :per_page).reverse_merge({ page: 1, per_page: 50 })
    opts[:page] = 1 if opts[:page].to_i < 1
    opts[:per_page] = 50 if opts[:per_page].to_i < 1 || opts[:per_page].to_i > 50
    opts
  end

  def collection_json(collection)
    {
      data: collection,
      meta: {
        total_pages: collection.total_pages,
        current_page: collection.current_page,
        per_page: collection.per_page,
        total_entries: collection.total_entries
      }
    }
  end
end
