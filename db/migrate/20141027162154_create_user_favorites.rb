class CreateUserFavorites < ActiveRecord::Migration
  def change
    create_table :user_favorites do |t|
      t.references :user, index: true
      t.references :favorite, index: true
      t.integer :ordering, default: 0

      t.timestamps
    end
  end
end
