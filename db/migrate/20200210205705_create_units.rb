class CreateUnits < ActiveRecord::Migration[6.0]
  def change
    create_table :units do |t|
      t.references :spawner, null: false
      t.binary :marshal_object
      t.boolean :active, default: true
      t.integer :attribute_health
      t.integer :coordinate_Y
      t.integer :coordinate_X
      t.integer :base_health
      t.integer :base_movement
      t.integer :base_range
      t.integer :base_melee
      t.integer :base_vision
      t.string :base_spawn_position
      t.boolean :error, default: false, null: false
      t.boolean :cancelled, default: false, null: false
      t.json :data_set
      t.json :error_history_array, array: true, default: [], null: false
      t.json :movement_history, default: {}, null: false
      t.integer :uuid, null: false, limit: 8
      t.string :colour, null: false
      t.json :unit_output_history_array, array: true, default: [], null: false
      t.boolean :new, null: false
      t.json :current_path, array: true, default: [], null: false
      t.string :target_coordinate_string
      t.integer :path_step_count, default: 0, null: false
      t.boolean :obstacle, default: false, null: false

      t.index :uuid, unique: true
      t.timestamps
    end
  end
end
