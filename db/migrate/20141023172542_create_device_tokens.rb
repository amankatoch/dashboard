class CreateDeviceTokens < ActiveRecord::Migration
  def change
    create_table :device_tokens do |t|
      t.string :token
      t.string :device_type
      t.references :user, index: true

      t.timestamps
    end
  end
end
