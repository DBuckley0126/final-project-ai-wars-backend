class CreateGames < ActiveRecord::Migration[6.0]
  def change
    create_table :games do |t|
      t.string :uuid, :null => false
      t.references :user_1, foreign_key: { to_table: 'users'}
      t.references :user_2, foreign_key: { to_table: 'users'}
      t.boolean :user_1_ready, default: false
      t.boolean :user_2_ready, default: false
      t.boolean :game_initiated, default: false
      t.string :user_1_colour
      t.string :user_2_colour

      t.index :uuid, unique: true
      t.timestamps
    end
  end
end
