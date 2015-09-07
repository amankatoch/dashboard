class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user, index: true
      t.references :related_user, index: true
      t.string :title
      t.text :message
      t.integer :status, default: 0
      t.string :category

      t.timestamps
    end
  end
end
