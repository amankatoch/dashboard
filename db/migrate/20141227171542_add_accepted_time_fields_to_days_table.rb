class AddAcceptedTimeFieldsToDaysTable < ActiveRecord::Migration
  def change
    add_column :session_requests_days, :accepted_time_start, :time
    add_column :session_requests_days, :accepted_time_end, :time
  end
end
