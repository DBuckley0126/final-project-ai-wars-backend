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

ActiveRecord::Schema.define(version: 2020_02_20_205705) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "games", force: :cascade do |t|
    t.string "uuid", null: false
    t.integer "host_user_id"
    t.string "host_user_type"
    t.integer "join_user_id"
    t.string "join_user_type"
    t.boolean "host_user_ready", default: false
    t.boolean "join_user_ready", default: false
    t.boolean "game_initiated", default: false
    t.string "host_user_colour"
    t.string "join_user_colour"
    t.string "status", default: "LOBBY"
    t.integer "turn_count", default: 0
    t.json "map_state", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["uuid"], name: "index_games_on_uuid", unique: true
  end

  create_table "spawners", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.bigint "user_id", null: false
    t.text "code_string", default: ""
    t.boolean "active", default: true, null: false
    t.string "colour", default: "#7aa9de", null: false
    t.json "skill_points", default: {"melee"=>0, "range"=>0, "vision"=>0, "health"=>0, "movement"=>0}, null: false
    t.boolean "passed_initial_test", null: false
    t.boolean "error", default: false, null: false
    t.boolean "cancelled", default: false, null: false
    t.json "error_history_array", default: [], null: false, array: true
    t.string "spawner_name", default: "Unit", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_spawners_on_game_id"
    t.index ["user_id"], name: "index_spawners_on_user_id"
  end

  create_table "turns", force: :cascade do |t|
    t.bigint "game_id"
    t.bigint "user_id"
    t.json "errors_for_turn_array", default: [], null: false, array: true
    t.json "user_turn_payload"
    t.bigint "uuid"
    t.json "units_output_for_turn_array", default: [], null: false, array: true
    t.json "current_game_state"
    t.integer "turn_count"
    t.json "map_states_for_turn", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_turns_on_game_id"
    t.index ["user_id"], name: "index_turns_on_user_id"
  end

  create_table "units", force: :cascade do |t|
    t.bigint "spawner_id", null: false
    t.binary "marshal_object", null: false
    t.boolean "active", default: true
    t.integer "attribute_health"
    t.integer "coordinate_Y"
    t.integer "coordinate_X"
    t.integer "base_health"
    t.integer "base_movement"
    t.integer "base_range"
    t.integer "base_melee"
    t.integer "base_vision"
    t.string "base_spawn_position"
    t.boolean "error", default: false, null: false
    t.boolean "cancelled", default: false, null: false
    t.json "data_set"
    t.json "error_history_array", default: [], null: false, array: true
    t.json "movement_history", default: {}, null: false
    t.bigint "uuid", null: false
    t.string "colour", null: false
    t.json "unit_output_history_array", default: [], null: false, array: true
    t.boolean "new", null: false
    t.json "current_path", default: [], null: false, array: true
    t.string "target_coordinate_string"
    t.integer "path_step_count", default: 0, null: false
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

end
