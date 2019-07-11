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

ActiveRecord::Schema.define(version: 2015_08_13_210811) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "awards", id: :serial, force: :cascade do |t|
    t.bigint "student_id"
    t.bigint "course_id"
    t.integer "badge_id"
    t.date "class_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "teacher_id"
    t.string "tool_consumer_instance_guid"
    t.index ["course_id", "class_date", "tool_consumer_instance_guid"], name: "index_awards_on_course_date_tciguid"
    t.index ["student_id", "course_id", "class_date", "badge_id", "tool_consumer_instance_guid"], name: "index_awards_uniquely", unique: true
    t.index ["student_id", "course_id", "class_date", "tool_consumer_instance_guid"], name: "index_awards_on_course_student_date_tciguid"
  end

  create_table "badges", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "icon"
    t.string "color"
    t.bigint "course_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "account_id"
    t.string "tool_consumer_instance_guid"
    t.index ["account_id", "tool_consumer_instance_guid"], name: "index_badges_on_account_id_and_tool_consumer_instance_guid"
    t.index ["course_id", "tool_consumer_instance_guid"], name: "index_badges_on_course_id_and_tool_consumer_instance_guid"
  end

  create_table "cached_accounts", id: :serial, force: :cascade do |t|
    t.bigint "parent_account_id"
    t.datetime "last_sync_on"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "tool_consumer_instance_guid"
    t.bigint "account_id", null: false
    t.index ["account_id", "tool_consumer_instance_guid"], name: "index_cached_accounts_on_account_id_and_tciguid"
    t.index ["parent_account_id", "tool_consumer_instance_guid"], name: "index_cached_accounts_on_parent_account_id_and_tciguid"
  end

  create_table "canvas_oauth_authorizations", id: :serial, force: :cascade do |t|
    t.bigint "canvas_user_id"
    t.string "token"
    t.datetime "last_used_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "tool_consumer_instance_guid", null: false
    t.index ["canvas_user_id", "tool_consumer_instance_guid"], name: "index_canvas_oauth_auths_on_user_id_and_tciguid"
  end

  create_table "course_configs", id: :serial, force: :cascade do |t|
    t.bigint "course_id"
    t.float "tardy_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "view_preference"
    t.string "tool_consumer_instance_guid"
    t.index ["course_id", "tool_consumer_instance_guid"], name: "index_course_configs, uniquely", unique: true
  end

  create_table "lti_provider_launches", id: :serial, force: :cascade do |t|
    t.string "canvas_url"
    t.string "nonce"
    t.text "provider_params"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["nonce", "created_at"], name: "index_lti_provider_launches_on_nonce_and_created_at"
  end

  create_table "seating_charts", id: :serial, force: :cascade do |t|
    t.bigint "course_id"
    t.bigint "section_id"
    t.date "class_date"
    t.text "assignments"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "tool_consumer_instance_guid"
    t.index ["section_id", "class_date", "tool_consumer_instance_guid"], name: "index_seating_charts_on_section_date_tciguid"
  end

  create_table "statuses", id: :serial, force: :cascade do |t|
    t.bigint "student_id"
    t.bigint "section_id"
    t.date "class_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "attendance", limit: 20
    t.bigint "course_id"
    t.bigint "account_id"
    t.bigint "teacher_id"
    t.string "tool_consumer_instance_guid"
    t.boolean "fixed"
    t.index ["account_id", "tool_consumer_instance_guid"], name: "index_statuses_on_account_id_and_tool_consumer_instance_guid"
    t.index ["course_id", "tool_consumer_instance_guid"], name: "index_statuses_on_course_id_and_tool_consumer_instance_guid"
    t.index ["section_id", "class_date", "tool_consumer_instance_guid"], name: "index_statuses_on_section_date_tciguid"
    t.index ["student_id", "section_id", "class_date", "tool_consumer_instance_guid"], name: "index_statuses_uniquely", unique: true
    t.index ["student_id", "tool_consumer_instance_guid"], name: "index_statuses_on_student_id_and_tool_consumer_instance_guid"
  end

end
