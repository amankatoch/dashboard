class CreateSessionRequestsDays < ActiveRecord::Migration
  def change
    create_table :session_requests_days do |t|
      t.references :session_request
      t.date :date
      t.time :time_start
      t.time :time_end

      t.timestamps
    end
  end
end
