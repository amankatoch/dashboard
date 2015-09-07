class CreateSessionRequests < ActiveRecord::Migration
  def change
    create_table :session_requests do |t|
      t.references :invited_user, index: true
      t.references :user, index: true
      t.string :message
      t.integer :status, default: 0
      t.datetime :accepted_rejected_at

      t.timestamps
    end
  end
end
