class CreateTurns < ActiveRecord::Migration[6.0]
  def change
    create_table :turns do |t|
      t.belongs_to :game
      t.belongs_to :user
      t.json :errors_for_turn_array, array: true, default: [], null: false
      t.json :user_turn_payload
      t.integer :uuid, limit: 8
      t.json :units_output_for_turn_array, array: true, default: [], null: false
      t.json :current_game_state
      t.integer :turn_count
      t.integer :step_count, default: 0, null: false
      t.json :map_states_for_turn, default: {}, null: false

      # t.index :uuid, unique: true
      t.timestamps
    end
  end
end
