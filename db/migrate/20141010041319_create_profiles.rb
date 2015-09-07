class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :name
      t.integer :age
      t.string :gender
      t.string :location
      t.text :about
      t.integer :level
      t.references :user

      t.timestamps
    end
  end
end
