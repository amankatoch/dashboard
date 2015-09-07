class CreateApiTokens < ActiveRecord::Migration
  def change
    create_table :api_tokens do |t|
      t.string :name
      t.string :token
      t.datetime :last_used_at

      t.timestamps
    end
  end
end
