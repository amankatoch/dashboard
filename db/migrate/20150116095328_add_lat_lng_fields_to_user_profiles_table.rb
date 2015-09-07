class AddLatLngFieldsToUserProfilesTable < ActiveRecord::Migration
  def change
    add_column :profiles, :lat, :float
    add_column :profiles, :lng, :float
    add_earthdistance_index :profiles
  end
end
