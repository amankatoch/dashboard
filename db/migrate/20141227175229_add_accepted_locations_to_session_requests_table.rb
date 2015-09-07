class AddAcceptedLocationsToSessionRequestsTable < ActiveRecord::Migration
  def change
    add_column :session_requests, :accepted_locations, :string, array: true
  end
end
