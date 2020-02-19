class CreateTurns < ActiveRecord::Migration[6.0]
  def change
    create_table :turns do |t|
      t.belongs_to :game
      t.belongs_to :user
      t.json :errors_for_turn, default: {}, null: false
      t.json :user_turn_payload
      t.integer :uuid
      t.json :units_output_for_turn, default: {}, null: false
      t.json :current_game_state

      # t.index :uuid, unique: true
      t.timestamps
    end
  end
end
