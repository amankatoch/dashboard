class AddAcceptedColumnToSessionRequestsDays < ActiveRecord::Migration
  def change
    add_column :session_requests_days, :accepted, :boolean, default: nil
  end
end
