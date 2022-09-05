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

ActiveRecord::Schema[7.0].define(version: 2022_07_21_214402) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "year", default: 0, null: false
    t.integer "month", default: 0, null: false
    t.string "month_in_words", default: "", null: false
    t.string "username", limit: 20, default: "", null: false
    t.string "email", limit: 70
    t.string "password_digest"
    t.integer "login_count", default: 0, null: false
    t.datetime "last_login_at", null: false
    t.string "last_login_ip", default: "", null: false
    t.text "logged_in_ips", default: [], array: true
    t.boolean "is_user_active", default: true
    t.string "valid_token", default: "", null: false
    t.uuid "reset_password_id"
    t.datetime "reset_password_expiration"
    t.integer "max_password_failed_attempts", default: 6, null: false
    t.integer "password_failed_attempts", default: 0, null: false
    t.boolean "is_user_locked", default: false
    t.datetime "user_locked_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
    t.index ["reset_password_id"], name: "index_users_on_reset_password_id"
    t.index ["username"], name: "index_users_on_username"
  end

end
