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

describe SectionsController do
  let(:section) { Section.new(id: 1, course_id: 1 ) }
  let(:sections) { [section, Section.new(id: 2)] }
  let(:tool_consumer_instance_guid) { 'abc123' }

  before do
    allow(controller).to receive(:require_lti_launch)
    allow(controller).to receive(:request_canvas_authentication)
    allow(controller).to receive_messages(enrollments_section_ids: [1])
    allow(controller).to receive(:can_grade)
    session[:tool_consumer_instance_guid] = 'abc123'
  end

  describe "GET course" do
    before do
      allow(controller).to receive(:load_and_authorize_sections)
        .and_return(sections)
      allow(controller).to receive(:prepare_course)
    end

    it "redirects to the first section" do
      get :course, params: { course_id: 1 }
      expect(response).to redirect_to section_path(1)
    end

    it "should try loading sections even if you have no enrollments (for admins)" do
      allow(controller).to receive_messages(enrollment_section_ids: [])
      get :course, params: { course_id: 1 }
      expect(response).to redirect_to section_path(1)
    end
  end

  describe "GET show" do
    before do
      allow(controller).to receive(:cached_sections)
      allow(controller).to receive(:load_and_authorize_sections)
        .and_return(sections)
      allow(controller).to receive(:load_and_authorize_full_section).and_return(section)
    end

    it "sets the @sections to the list of all sections" do
      allow(controller).to receive(:load_and_authorize_enrollments).and_return([{
        'type' => 'TeacherEnrollment',
        'course_id' => 1,
        'course_section_id' => 1
      }])
      allow(controller).to receive(:load_and_authorize_full_section)
        .with('1', tool_consumer_instance_guid)
        .and_return(section)
      allow(controller).to receive(:load_and_authorize_sections)
        .with('1', tool_consumer_instance_guid)
        .and_return(sections)

      get :show, params: { section_id: '1' }
      expect(assigns(:sections)).to eq(sections)
    end

    it "sets the @section to the full section" do
      allow(controller).to receive(:load_and_authorize_enrollments).and_return([{
        'type' => 'TeacherEnrollment',
        'course_id' => 1,
        'course_section_id' => 1
      }])
      allow(controller).to receive(:load_and_authorize_full_section)
        .with('1', tool_consumer_instance_guid)
        .and_return(section)
      allow(controller).to receive(:load_and_authorize_sections)
        .with('1', tool_consumer_instance_guid)
        .and_return(sections)

      get :show, params: { section_id: '1' }
      expect(assigns(:section)).to eq(section)
    end

    it "renders an error if the section is nil" do
      allow(controller).to receive(:load_and_authorize_full_section).and_return(nil)
      expect(controller).to receive(:render_error)
      get :show, params: { section_id: '1' }
    end

    it "renders an error if the section list is nil" do
      allow(controller).to receive(:load_and_authorize_enrollments).and_return([{
        'type' => 'TeacherEnrollment',
        'course_id' => 3,
        'course_section_id' => 1
      }])
      allow(controller).to receive(:load_and_authorize_full_section)
        .with('1', tool_consumer_instance_guid)
        .and_return(section)
      allow(controller).to receive(:section_limited?).and_return(true)
      allow(controller).to receive(:load_and_authorize_sections).and_return([])
      expect(controller).to receive(:render_error)

      get :show, params: { section_id: 1 }

      expect(assigns(:section)).to eq(section)
      expect(assigns(:sections)).to eq([])
    end

    it "renders other section when not authorized" do
      allow(controller).to receive(:load_and_authorize_enrollments).and_return([{
        'type' => 'TeacherEnrollment',
        'course_id' => 1,
        'course_section_id' => 3
      }])
      allow(controller).to receive(:load_and_authorize_full_section)
        .with('3', tool_consumer_instance_guid)
        .and_return(Section.new(id: 3, course_id: 2 ))
      allow(controller).to receive(:load_and_authorize_sections)
        .and_return(sections)
      allow(controller).to receive(:section_limited?).and_return(true)
      allow(controller).to receive(:enrollments_section_ids).and_return([1,2])

      get :show, params: { section_id: 3 }

      expect(assigns(:section)).to eq(sections.first)
      expect(assigns(:sections)).to eq(sections)
    end

    it "renders an error due to the authorization of the list of sections" do
      other_section = Section.new(id: 3, course_id: 2 )
      allow(controller).to receive(:load_and_authorize_enrollments).and_return([{
        'type' => 'TeacherEnrollment',
        'course_id' => 1,
        'course_section_id' => 3
      }])
      allow(controller).to receive(:load_and_authorize_full_section)
        .with('1', tool_consumer_instance_guid)
        .and_return(other_section)
      allow(controller).to receive(:load_and_authorize_sections)
        .and_return(sections)
      allow(controller).to receive(:section_limited?).and_return(true)
      allow(controller).to receive(:enrollments_section_ids).and_return([3])
      expect(controller).to receive(:render_error)

      get :show, params: { section_id: 1 }

      expect(assigns(:section)).to eq(other_section)
      expect(assigns(:sections)).to eq([])
    end

    it "renders an error when the teacher is not enrolled in any section of that course" do
      allow(controller).to receive(:load_and_authorize_enrollments).and_return([{
        'type' => 'TeacherEnrollment',
        'course_id' => 3,
        'course_section_id' => 2
      }])
      allow(controller).to receive(:load_and_authorize_full_section)
        .with('1', tool_consumer_instance_guid)
        .and_return(section)
      allow(controller).to receive(:load_and_authorize_sections)
        .and_return(sections)
      allow(controller).to receive(:section_limited?).and_return(true)
      allow(controller).to receive(:enrollments_section_ids).and_return([3])

      expect(controller).to receive(:render_error)

      get :show, params: { section_id: 1 }

      expect(assigns(:section)).to eq(nil)
      expect(assigns(:sections)).to eq([])
    end

    it "renders more than 100 sections" do
      long_sections_list = []
      long_sections_ids_list = []
      150.times do |index|
        new_section = section
        new_section.id = index + 1

        long_sections_list << new_section
        long_sections_ids_list << index + 1
      end

      allow(controller).to receive(:load_and_authorize_enrollments).and_return([{
        'type' => 'TeacherEnrollment',
        'course_id' => 3,
        'course_section_id' => 2
      }])
      allow(controller).to receive(:load_and_authorize_full_section)
        .with('1', tool_consumer_instance_guid)
        .and_return(section)
      allow(controller).to receive(:load_and_authorize_sections).and_return(long_sections_list)
      allow(controller).to receive(:section_limited?).and_return(true)
      allow(controller).to receive(:enrollments_section_ids).and_return(long_sections_ids_list)

      get :show, params: { section_id: 1 }

      expect(assigns(:section)).to eq(section)
      expect(assigns(:sections)).to eq(long_sections_list)
    end

    it "renders 120 sections of 150 due to authorization" do
      long_sections_list = []
      long_sections_ids_list = []

      150.times do |index|
        long_sections_list << Section.new(id: index, course_id: 1 )
      end

      120.times do |index|
        long_sections_ids_list << index
      end

      allow(controller).to receive(:load_and_authorize_enrollments).and_return([{
        'type' => 'TeacherEnrollment',
        'course_id' => 3,
        'course_section_id' => 2
      }])
      allow(controller).to receive(:load_and_authorize_full_section)
        .with('1', tool_consumer_instance_guid)
        .and_return(section)
      allow(controller).to receive(:load_and_authorize_sections).and_return(long_sections_list)
      allow(controller).to receive(:section_limited?).and_return(true)
      allow(controller).to receive(:enrollments_section_ids).and_return(long_sections_ids_list)

      get :show, params: { section_id: 1 }

      expect(assigns(:section)).to eq(section)
      expect(assigns(:sections).count).to eq(long_sections_ids_list.count)
    end

    it "should limit to specific section if flag is set" do
      allow(controller).to receive(:section_limited?).and_return(true)
      get :show, params: { section_id: '1' }
      expect(assigns(:sections)).to eq([section])
    end
  end

  describe "prepare_course" do
    it "refreshes the course info from canvas" do
      expect(controller).to receive(:refresh_course_with_sections!)
      expect(controller).to receive(:refresh_user_enrollments!)
      controller.send(:prepare_course)
    end
  end

  describe "enrollments_section_ids" do
    before do
      allow(controller).to receive(:enrollments_section_ids).and_call_original
      allow(controller).to receive(:user_id).and_return(5)
    end

    it "should work with a enrollment-like object" do
      allow(controller).to receive(:load_and_authorize_enrollments).and_return([{
        'type' => 'TeacherEnrollment',
        'course_id' => 1,
        'course_section_id' => 2
      }])
      expect(controller.send(:enrollments_section_ids, 1, tool_consumer_instance_guid)).to eq([2])
    end

    it "should be empty if there are no authorized enrollments" do
      allow(controller).to receive(:load_and_authorize_enrollments).and_return(nil)
      expect(controller.send(:enrollments_section_ids, 1, tool_consumer_instance_guid)).to eq([])
    end
  end
end
