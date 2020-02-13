class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :given_name
      t.string :family_name
      t.string :locale
      t.string :picture
      t.string :email
      t.string :sub, :null => false
      t.string :uuid

      t.index :sub, unique: true


      t.timestamps
    end
  end
end
