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

ActiveRecord::Schema.define(version: 20150327183033) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "cube"
  enable_extension "earthdistance"

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true, using: :btree
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true, using: :btree

  create_table "api_tokens", force: true do |t|
    t.string   "name"
    t.string   "token"
    t.datetime "last_used_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "beta_requests", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "device_tokens", force: true do |t|
    t.string   "token"
    t.string   "device_type"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "device_tokens", ["user_id"], name: "index_device_tokens_on_user_id", using: :btree

  create_table "notifications", force: true do |t|
    t.integer  "user_id"
    t.integer  "related_user_id"
    t.string   "title"
    t.text     "message"
    t.integer  "status",          default: 0
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notifications", ["related_user_id"], name: "index_notifications_on_related_user_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "payments", force: true do |t|
    t.float    "amount"
    t.integer  "status"
    t.string   "stripe_charge_id"
    t.integer  "session_request_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "transfer_id"
    t.datetime "transferred_at"
  end

  add_index "payments", ["session_request_id"], name: "index_payments_on_session_request_id", using: :btree

  create_table "profile_availabilities", force: true do |t|
    t.integer  "profile_id"
    t.string   "day"
    t.string   "time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profile_availabilities", ["profile_id"], name: "index_profile_availabilities_on_profile_id", using: :btree

  create_table "profile_skills", force: true do |t|
    t.integer  "profile_id"
    t.integer  "skill_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profile_skills", ["profile_id"], name: "index_profile_skills_on_profile_id", using: :btree
  add_index "profile_skills", ["skill_id"], name: "index_profile_skills_on_skill_id", using: :btree

  create_table "profiles", force: true do |t|
    t.string   "name"
    t.integer  "age"
    t.string   "gender"
    t.string   "location"
    t.text     "about"
    t.decimal  "level",           precision: 2, scale: 1
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_public_id"
    t.float    "lat"
    t.float    "lng"
    t.float    "hourly_rate"
  end

  create_table "session_requests", force: true do |t|
    t.integer  "invited_user_id"
    t.integer  "user_id"
    t.string   "message"
    t.integer  "status",               default: 0
    t.datetime "accepted_rejected_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "invited_user_comment"
    t.string   "locations",                        array: true
    t.string   "accepted_locations",               array: true
    t.string   "location"
  end

  add_index "session_requests", ["invited_user_id"], name: "index_session_requests_on_invited_user_id", using: :btree
  add_index "session_requests", ["user_id"], name: "index_session_requests_on_user_id", using: :btree

  create_table "session_requests_days", force: true do |t|
    t.integer  "session_request_id"
    t.date     "date"
    t.time     "time_start"
    t.time     "time_end"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "accepted"
    t.time     "accepted_time_start"
    t.time     "accepted_time_end"
    t.boolean  "confirmed",           default: false
  end

  create_table "sessions_feedbacks", force: true do |t|
    t.integer  "session_request_id"
    t.integer  "by_user_id"
    t.integer  "for_user_id"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions_feedbacks", ["by_user_id"], name: "index_sessions_feedbacks_on_by_user_id", using: :btree
  add_index "sessions_feedbacks", ["for_user_id"], name: "index_sessions_feedbacks_on_for_user_id", using: :btree
  add_index "sessions_feedbacks", ["session_request_id"], name: "index_sessions_feedbacks_on_session_request_id", using: :btree

  create_table "sessions_feedbacks_skills", id: false, force: true do |t|
    t.integer "skill_id"
    t.integer "sessions_feedback_id"
  end

  add_index "sessions_feedbacks_skills", ["sessions_feedback_id"], name: "index_sessions_feedbacks_skills_on_sessions_feedback_id", using: :btree
  add_index "sessions_feedbacks_skills", ["skill_id"], name: "index_sessions_feedbacks_skills_on_skill_id", using: :btree

  create_table "settings", force: true do |t|
    t.string   "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "skills", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", force: true do |t|
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_favorites", force: true do |t|
    t.integer  "user_id"
    t.integer  "favorite_id"
    t.integer  "ordering",    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_favorites", ["favorite_id"], name: "index_user_favorites_on_favorite_id", using: :btree
  add_index "user_favorites", ["user_id"], name: "index_user_favorites_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                            default: "", null: false
    t.string   "encrypted_password",               default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string   "authentication_token"
    t.integer  "sign_in_count",                    default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "stripe_customer_id"
    t.string   "facebook_access_token"
    t.integer  "facebook_id",            limit: 8
    t.string   "stripe_recipient_id"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
