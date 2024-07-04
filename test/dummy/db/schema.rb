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

ActiveRecord::Schema[7.1].define(version: 2021_08_31_172021) do
  create_table "users", force: :cascade do |t|
    t.boolean "active", default: false
    t.string "email"
    t.string "crypted_password"
    t.string "salt"
    t.datetime "last_logged_in_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "username"
    t.string "password_hash"
    t.integer "using_digest_version"
    t.string "verification_token"
    t.datetime "verification_token_generated_at", precision: nil
    t.datetime "email_verified_at", precision: nil
    t.index ["verification_token"], name: "index_users_on_verification_token", unique: true
  end

end
