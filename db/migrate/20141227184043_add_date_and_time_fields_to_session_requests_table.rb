class AddDateAndTimeFieldsToSessionRequestsTable < ActiveRecord::Migration
  def change
    add_column :session_requests, :location, :string
    add_column :session_requests_days, :confirmed, :boolean, default: false
  end
end
