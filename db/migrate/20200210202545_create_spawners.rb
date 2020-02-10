class CreateSpawners < ActiveRecord::Migration[6.0]
  def change
    create_table :spawners do |t|
      t.string :uuid, :null => false
      t.references :game
      t.references :user
      t.text :code
      t.boolean :active, default: true

      t.index :uuid, unique: true
      t.timestamps
    end
  end
end
