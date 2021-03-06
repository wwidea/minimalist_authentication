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

ActiveRecord::Schema.define(version: 20170927191119) do

  create_table "users", force: :cascade do |t|
    t.boolean "active"
    t.string "email"
    t.string "crypted_password"
    t.string "salt"
    t.datetime "last_logged_in_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "password_hash"
    t.integer "using_digest_version"
    t.string "verification_token"
    t.datetime "verification_token_generated_at"
    t.datetime "email_verified_at"
    t.index ["verification_token"], name: "index_users_on_verification_token", unique: true
  end

end
