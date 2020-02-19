class CreateUnits < ActiveRecord::Migration[6.0]
  def change
    create_table :units do |t|
      t.references :spawner
      t.text :marshal_object
      t.boolean :active, default: true
      t.integer :attribute_health
      t.integer :coordinate_Y
      t.integer :coordinate_X
      t.json :data_set
      t.json :error_history, default: {}, null: false
      t.integer :uuid
      t.string :colour
      t.json :unit_output_history

      t.index :uuid, unique: true
      t.timestamps
    end
  end
end
