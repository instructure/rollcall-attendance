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

require "resque/server"

InstructureRollcall::Application.routes.draw do
  resources :seating_charts, only: [:show, :create]

  resources :statuses

  get '/courses/:course_id',   to: 'sections#course', as: 'course'
  get '/sections/:section_id', to: 'sections#show', as: 'section'
  scope '/courses/:course_id' do
    resources :students, only: [:show] do
      resources :student_statuses, only: [:index] do
        get 'summary', on: :collection
      end
    end
  end

  get 'course/:course_id/badges', to: 'badges#course'

  resources :accounts, only: [:show] do
    member do
      get :badges
    end
  end

  resources :badges
  resources :awards, only: [:index, :create, :destroy] do
    collection do
      get 'stats'
    end
  end
  resources :course_configs
  resources :reports, only: [:create, :new]

  get 'health_check', to: 'home#liveness'
  get 'liveness', to: 'home#liveness'
  get 'readiness', to: 'home#readiness'
  root to: 'home#index'

  mount SecureResqueServer.new, at: "/resque"
  mount LtiProvider::Engine, at: "/"
  mount CanvasOauth::Engine, at: "/canvas_oauth"

  mount JasmineRails::Engine => "/specs" if defined?(JasmineRails)
end
