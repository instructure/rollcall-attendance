# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_02_28_050242) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "awards", id: :serial, force: :cascade do |t|
    t.bigint "student_id"
    t.bigint "course_id"
    t.integer "badge_id"
    t.date "class_date"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
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
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "account_id"
    t.string "tool_consumer_instance_guid"
    t.index ["account_id", "tool_consumer_instance_guid"], name: "index_badges_on_account_id_and_tool_consumer_instance_guid"
    t.index ["course_id", "tool_consumer_instance_guid"], name: "index_badges_on_course_id_and_tool_consumer_instance_guid"
  end

  create_table "cached_accounts", id: :serial, force: :cascade do |t|
    t.bigint "parent_account_id"
    t.datetime "last_sync_on", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "tool_consumer_instance_guid"
    t.bigint "account_id", null: false
    t.index ["account_id", "tool_consumer_instance_guid"], name: "index_cached_accounts_on_account_id_and_tciguid"
    t.index ["parent_account_id", "tool_consumer_instance_guid"], name: "index_cached_accounts_on_parent_account_id_and_tciguid"
  end

  create_table "canvas_oauth_authorizations", id: :serial, force: :cascade do |t|
    t.bigint "canvas_user_id"
    t.string "token"
    t.datetime "last_used_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "tool_consumer_instance_guid", null: false
    t.index ["canvas_user_id", "tool_consumer_instance_guid"], name: "index_canvas_oauth_auths_on_user_id_and_tciguid"
  end

  create_table "course_configs", id: :serial, force: :cascade do |t|
    t.bigint "course_id"
    t.float "tardy_weight"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "view_preference"
    t.string "tool_consumer_instance_guid"
    t.boolean "omit_from_final_grade", default: false, null: false
    t.index ["course_id", "tool_consumer_instance_guid"], name: "index_course_configs, uniquely", unique: true
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.string "queue", limit: 255, null: false
    t.datetime "run_at", precision: nil, null: false
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "tag", limit: 255
    t.integer "max_attempts"
    t.string "strand", limit: 255
    t.boolean "next_in_strand", default: true, null: false
    t.string "source", limit: 255
    t.integer "max_concurrent", default: 1, null: false
    t.datetime "expires_at", precision: nil
    t.integer "strand_order_override", default: 0, null: false
    t.string "singleton"
    t.index ["locked_by"], name: "index_delayed_jobs_on_locked_by", where: "(locked_by IS NOT NULL)"
    t.index ["queue", "priority", "run_at", "id"], name: "get_delayed_jobs_index", where: "((locked_at IS NULL) AND next_in_strand)"
    t.index ["run_at", "tag"], name: "index_delayed_jobs_on_run_at_and_tag"
    t.index ["singleton"], name: "index_delayed_jobs_on_singleton_not_running", unique: true, where: "((singleton IS NOT NULL) AND ((locked_by IS NULL) OR ((locked_by)::text = 'on hold'::text)))"
    t.index ["singleton"], name: "index_delayed_jobs_on_singleton_running", unique: true, where: "((singleton IS NOT NULL) AND (locked_by IS NOT NULL) AND ((locked_by)::text <> 'on hold'::text))"
    t.index ["strand", "id"], name: "index_delayed_jobs_on_strand"
    t.index ["strand", "next_in_strand", "id"], name: "n_strand_index", where: "(strand IS NOT NULL)"
    t.index ["strand", "strand_order_override", "id"], name: "next_in_strand_index", where: "(strand IS NOT NULL)"
    t.index ["tag"], name: "index_delayed_jobs_on_tag"
  end

  create_table "failed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.string "handler", limit: 512000
    t.text "last_error"
    t.string "queue", limit: 255
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by", limit: 255
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "tag", limit: 255
    t.integer "max_attempts"
    t.string "strand", limit: 255
    t.bigint "original_job_id"
    t.string "source", limit: 255
    t.datetime "expires_at", precision: nil
    t.integer "strand_order_override", default: 0, null: false
    t.string "singleton"
    t.bigint "requeued_job_id"
    t.index ["failed_at"], name: "index_failed_jobs_on_failed_at"
    t.index ["singleton"], name: "index_failed_jobs_on_singleton", where: "(singleton IS NOT NULL)"
    t.index ["strand"], name: "index_failed_jobs_on_strand", where: "(strand IS NOT NULL)"
    t.index ["tag"], name: "index_failed_jobs_on_tag"
  end

  create_table "lti_provider_launches", id: :serial, force: :cascade do |t|
    t.string "canvas_url"
    t.string "nonce"
    t.text "provider_params"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["nonce", "created_at"], name: "index_lti_provider_launches_on_nonce_and_created_at"
  end

  create_table "seating_charts", id: :serial, force: :cascade do |t|
    t.bigint "course_id"
    t.bigint "section_id"
    t.date "class_date"
    t.text "assignments"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "tool_consumer_instance_guid"
    t.index ["section_id", "class_date", "tool_consumer_instance_guid"], name: "index_seating_charts_on_section_date_tciguid"
  end

  create_table "statuses", id: :serial, force: :cascade do |t|
    t.bigint "student_id"
    t.bigint "section_id"
    t.date "class_date"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
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
