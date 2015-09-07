class AddFacebookColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_access_token, :string
    add_column :users, :facebook_id, :bigint
  end
end
