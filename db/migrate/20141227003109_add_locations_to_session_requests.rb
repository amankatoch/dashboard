class AddLocationsToSessionRequests < ActiveRecord::Migration
  def change
    add_column :session_requests, :locations, :string, array: true
  end
end
