class CreateSpawners < ActiveRecord::Migration[6.0]
  def change
    create_table :spawners do |t|
      t.references :game, null: false
      t.references :user, null: false
      t.text :code_string, default: ""
      t.boolean :active, default: true, null: false
      t.string :colour, default: "#7aa9de", null: false
      t.json :skill_points, default: {melee: 0, range: 0, vision: 0, health: 0, movement: 0}, null: false
      t.boolean :passed_initial_test, null: false
      t.boolean :error, default: false, null: false
      t.boolean :cancelled, default: false, null: false
      t.json :error_history_array, array: true, default: [], null: false
      t.string :spawner_name, default: "Unit", null: false
      t.boolean :obstacle_spawner, default: false, null: false
      t.timestamps
    end
  end
end
