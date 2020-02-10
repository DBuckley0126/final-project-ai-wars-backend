class CreateUnits < ActiveRecord::Migration[6.0]
  def change
    create_table :units do |t|
      t.string :uuid, :null => false
      t.references :spawner
      t.text :code
      t.boolean :active, default: true

      t.index :uuid, unique: true
      t.timestamps
    end
  end
end
