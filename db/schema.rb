# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_02_10_205705) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "user_1_id"
    t.bigint "user_2_id"
    t.boolean "user_1_ready"
    t.boolean "user_2_ready"
    t.boolean "game_initiated"
    t.string "user_1_colour"
    t.string "user_2_colour"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_1_id"], name: "index_games_on_user_1_id"
    t.index ["user_2_id"], name: "index_games_on_user_2_id"
    t.index ["uuid"], name: "index_games_on_uuid", unique: true
  end

  create_table "spawners", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "game_id"
    t.bigint "user_id"
    t.text "code"
    t.boolean "active", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_spawners_on_game_id"
    t.index ["user_id"], name: "index_spawners_on_user_id"
    t.index ["uuid"], name: "index_spawners_on_uuid", unique: true
  end

  create_table "units", force: :cascade do |t|
    t.string "uuid", null: false
    t.bigint "spawner_id"
    t.text "code"
    t.boolean "active", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["spawner_id"], name: "index_units_on_spawner_id"
    t.index ["uuid"], name: "index_units_on_uuid", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "given_name"
    t.string "family_name"
    t.string "locale"
    t.string "picture"
    t.string "email"
    t.string "sub", null: false
    t.string "uuid"
    t.integer "wins", default: 0
    t.integer "losses", default: 0
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["sub"], name: "index_users_on_sub", unique: true
  end

  add_foreign_key "games", "users", column: "user_1_id"
  add_foreign_key "games", "users", column: "user_2_id"
end
