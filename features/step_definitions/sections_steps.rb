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

When /^I go to take attendance(?: again)?$/ do
  visit root_path
  wait_for_sync
end

Then /^I should be on my first section and it should be the active tab$/ do
  expect(page).to have_select('section_select', selected: 'Section 1')
end

Then /^I should see a list of my sections$/ do
  page.should have_content "Section 1"
  page.should have_content "Section 2"
end

When /^I click the first section$/ do
  select "Section 1", :from => "section_select"
end

Given /^I am a teacher with (\d+) sections? and (\d+) (cross-shard )?students(?: in each)?$/ do |sections, students, cross_shard|
  # Responses for when each of the sections are queried
  enrollment_hashes = []
  sections.to_i.times do |i|
    section = i + 1
    user_id = cross_shard ? 10610000000574765 : 1
    enrollment_hashes << { course_id: 1, section_id: section, user_id: user_id }

    stub_request(:get, "http://test.canvas/api/v1/sections/#{section}").
      to_return(:status => 200, :body => create_section(section, students.to_i), headers: {'Content-Type' => 'application/json'})

    stub_request(:get, "http://test.canvas/api/v1/sections/#{section}/enrollments?per_page=50&page=first").
      to_return(:status => 200, :body => create_students(students.to_i), headers: {'Content-Type' => 'application/json'})

    stub_request(:get, "http://test.canvas/api/v1/courses/1/sections").
      to_return(:status => 200, :body => create_sections(sections.to_i, students.to_i), headers: {'Content-Type' => 'application/json'})

    stub_request(:get, "http://test.canvas/api/v1/courses/1/sections?page=1&per_page=50").
      to_return(:status => 200, :body => create_sections(sections.to_i, students.to_i), headers: {'Content-Type' => 'application/json'})
  end

  # # The Students
  stub_request(:get, "http://test.canvas/api/v1/courses/1/users?include%5B%5D=avatar_url&include%5B%5D=enrollments&include%5B%5D=email&include%5B%5D=observed_users&include%5B%5D=can_be_removed&include%5B%5D=custom_links&include_inactive=true&page=1&per_page=50").
    to_return(:status => 200, :body => create_students(students.to_i), headers: {'Content-Type' => 'application/json'})

  # The enrollments
  stub_request(:get, "http://test.canvas/api/v1/users/2/enrollments?per_page=50").
    with(:headers => {'Authorization'=>'Bearer'}).
    to_return(:status => 200, :body => enrollments_json(enrollment_hashes), headers: {'Content-Type' => 'application/json'})

  # The enrollments 2
  stub_request(:get, "http://test.canvas/api/v1/courses/1/enrollments?state"\
                     "%5B%5D=active&state%5B%5D=completed&type%5B%5D="\
                     "TaEnrollment&type%5B%5D=TeacherEnrollment&user_id=2&per_page=100").
    with(:headers => {'Authorization'=>'Bearer'}).
    to_return(
      :status => 200,
      :body => enrollments_json(enrollment_hashes),
      headers: {'Content-Type' => 'application/json'}
    )

  # Response for when the course is queried
  stub_request(:get, "http://test.canvas/api/v1/courses/1").
        with(:headers => {'Authorization'=>'Bearer'}).
        to_return(:status => 200, :body => '{"account_id":3, "id":1}', headers: {'Content-Type' => 'application/json'})

  # The attendance assignment exists, but make the ID nil, so we can skip the grade passback
  stub_request(:get, "http://test.canvas/api/v1/courses/1/assignments?per_page=50").
        with(:headers => {'Authorization'=>'Bearer'}).
        to_return(:status => 200, :body => '[{"id":null,"name":"Roll Call Attendance"}]', headers: {'Content-Type' => 'application/json'})

  # Send the section list
  stub_request(:get, "http://test.canvas/api/v1/courses/1/sections?include%5B0%5D=students&include%5B1%5D=avatar_url&include%5B2%5D=enrollments&per_page=50").
        with(:headers => {'Authorization'=>'Bearer'}).
        to_return(:status => 200, :body => create_sections(sections.to_i, students.to_i), headers: {'Content-Type' => 'application/json'})

end

def enrollments_json(enrollments)
  inner_json = enrollments.map do |enrollment|
    enrollment_json(enrollment[:course_id], enrollment[:section_id], enrollment[:user_id])
  end.join(",")
  "[#{inner_json}]"
end

def enrollment_json(course_id, section_id, user_id)
  <<-EOS.chomp
{"associated_user_id": null, "course_id": #{course_id}, "course_section_id": #{section_id}, "id": 1, "limit_privileges_to_course_section": false, "root_account_id": 1, "type": "TeacherEnrollment", "updated_at": "2013-03-15T12:33:14-06:00", "user_id": #{user_id}, "enrollment_state": "active", "role": "TeacherEnrollment", "html_url": "http://test.canvas/courses/#{course_id}/users/#{user_id}", "user": {"id": #{user_id}, "name": "foo@bar.com", "sortable_name": "foo@bar.com", "short_name": "foo@bar.com", "login_id": "foo@bar.com"}}
  EOS
end

def create_students(student_count)
    enrollment_hashes = []
    students = []
    student_count.times do |student_num|
      i = student_num+1
      enrollment_hashes << { course_id: 1, section_id: 1, user_id: i }

      enrollments = enrollments_json(enrollment_hashes)

      students << "{\"name\":\"student#{i}@12spokes.com\",\"short_name\":\"student#{i}@12spokes.com\",\"sortable_name\":\"student#{i}@12spokes.com\",\"id\":#{i}, \"enrollments\": #{enrollments}}"
    end

  "[" + students.join(",") + "]"
end

def create_section(section_num, student_count)

  students = create_students(student_count)

  "{\"name\":\"Section #{section_num}\",\"course_id\":1,\"sis_section_id\":null,\"id\":#{section_num},\"students\": #{students} }"
end

def create_sections(section_count, student_count)
  sections = []
  section_count.times do |section_num|
    section_num += 1
    students = []
    student_count.times do |student_num|
      i = student_num+1
      students << "{\"name\":\"student#{i}@12spokes.com\",\"short_name\":\"student#{i}@12spokes.com\",\"sortable_name\":\"student#{i}@12spokes.com\",\"id\":#{i}}"
    end
    sections << "{\"name\":\"Section #{section_num}\",\"course_id\":1,\"sis_section_id\":null,\"id\":#{section_num},\"students\":[#{students.join(',')}]}"
  end

  "[" + sections.join(",") + "]"
end
