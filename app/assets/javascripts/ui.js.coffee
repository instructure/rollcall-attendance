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

$ ->
  # Enable placeholder fallback for older browsers on all forms
  $("input, textarea").placeholder()

  # Dropdowns show/hide
  $(".rollcall-dropdown-toggle").click ->
    $(this).toggleClass("active").next(".rollcall-dropdown-list").toggleClass("visuallyhidden active")
    return false

  # Hide dropdown when user clicks anything else
  $("html").click ->
    if $(".rollcall-dropdown-list").is(":visible")
      $(".rollcall-dropdown-list").addClass("visuallyhidden").removeClass("active")
      $(".rollcall-dropdown-toggle").removeClass("active")
