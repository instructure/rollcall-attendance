# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150813210811) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "awards", force: :cascade do |t|
    t.integer  "student_id",                  limit: 8
    t.integer  "course_id",                   limit: 8
    t.integer  "badge_id"
    t.date     "class_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "teacher_id",                  limit: 8
    t.string   "tool_consumer_instance_guid"
  end

  add_index "awards", ["course_id", "class_date", "tool_consumer_instance_guid"], name: "index_awards_on_course_date_tciguid", using: :btree
  add_index "awards", ["student_id", "course_id", "class_date", "badge_id", "tool_consumer_instance_guid"], name: "index_awards_uniquely", unique: true, using: :btree
  add_index "awards", ["student_id", "course_id", "class_date", "tool_consumer_instance_guid"], name: "index_awards_on_course_student_date_tciguid", using: :btree

  create_table "badges", force: :cascade do |t|
    t.string   "name"
    t.string   "icon"
    t.string   "color"
    t.integer  "course_id",                   limit: 8
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
    t.string   "tool_consumer_instance_guid"
  end

  add_index "badges", ["account_id", "tool_consumer_instance_guid"], name: "index_badges_on_account_id_and_tool_consumer_instance_guid", using: :btree
  add_index "badges", ["course_id", "tool_consumer_instance_guid"], name: "index_badges_on_course_id_and_tool_consumer_instance_guid", using: :btree

  create_table "cached_accounts", force: :cascade do |t|
    t.integer  "parent_account_id",           limit: 8
    t.datetime "last_sync_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tool_consumer_instance_guid"
    t.integer  "account_id",                  limit: 8, null: false
  end

  add_index "cached_accounts", ["account_id", "tool_consumer_instance_guid"], name: "index_cached_accounts_on_account_id_and_tciguid", using: :btree
  add_index "cached_accounts", ["parent_account_id", "tool_consumer_instance_guid"], name: "index_cached_accounts_on_parent_account_id_and_tciguid", using: :btree

  create_table "canvas_oauth_authorizations", force: :cascade do |t|
    t.integer  "canvas_user_id",              limit: 8
    t.string   "token"
    t.datetime "last_used_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tool_consumer_instance_guid",           null: false
  end

  add_index "canvas_oauth_authorizations", ["canvas_user_id", "tool_consumer_instance_guid"], name: "index_canvas_oauth_auths_on_user_id_and_tciguid", using: :btree

  create_table "course_configs", force: :cascade do |t|
    t.integer  "course_id",                   limit: 8
    t.float    "tardy_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "view_preference"
    t.string   "tool_consumer_instance_guid"
  end

  add_index "course_configs", ["course_id", "tool_consumer_instance_guid"], name: "index_course_configs, uniquely", unique: true, using: :btree

  create_table "lti_provider_launches", force: :cascade do |t|
    t.string   "canvas_url"
    t.string   "nonce"
    t.text     "provider_params"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "lti_provider_launches", ["nonce", "created_at"], name: "index_lti_provider_launches_on_nonce_and_created_at", using: :btree

  create_table "seating_charts", force: :cascade do |t|
    t.integer  "course_id",                   limit: 8
    t.integer  "section_id",                  limit: 8
    t.date     "class_date"
    t.text     "assignments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tool_consumer_instance_guid"
  end

  add_index "seating_charts", ["section_id", "class_date", "tool_consumer_instance_guid"], name: "index_seating_charts_on_section_date_tciguid", using: :btree

  create_table "statuses", force: :cascade do |t|
    t.integer  "student_id",                  limit: 8
    t.integer  "section_id",                  limit: 8
    t.date     "class_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "attendance",                  limit: 20
    t.integer  "course_id",                   limit: 8
    t.integer  "account_id",                  limit: 8
    t.integer  "teacher_id",                  limit: 8
    t.string   "tool_consumer_instance_guid"
    t.boolean  "fixed"
  end

  add_index "statuses", ["account_id", "tool_consumer_instance_guid"], name: "index_statuses_on_account_id_and_tool_consumer_instance_guid", using: :btree
  add_index "statuses", ["course_id", "tool_consumer_instance_guid"], name: "index_statuses_on_course_id_and_tool_consumer_instance_guid", using: :btree
  add_index "statuses", ["section_id", "class_date", "tool_consumer_instance_guid"], name: "index_statuses_on_section_date_tciguid", using: :btree
  add_index "statuses", ["student_id", "section_id", "class_date", "tool_consumer_instance_guid"], name: "index_statuses_uniquely", unique: true, using: :btree
  add_index "statuses", ["student_id", "tool_consumer_instance_guid"], name: "index_statuses_on_student_id_and_tool_consumer_instance_guid", using: :btree

end
