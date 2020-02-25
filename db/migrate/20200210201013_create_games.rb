class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.string :uuid, :null => false
      t.integer :host_user_id
      t.string :host_user_type
      t.integer :join_user_id
      t.string :join_user_type
      t.boolean :host_user_ready, default: false
      t.boolean :join_user_ready, default: false
      t.boolean :game_initiated, default: false
      t.string :host_user_colour
      t.string :join_user_colour
      t.string :status, default: "LOBBY"
      t.integer :turn_count, default: 0
      t.json :map_state, default: {}, null: false

      t.index :uuid, unique: true
      t.timestamps
    end
  end
end
