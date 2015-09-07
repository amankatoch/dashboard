class CreateSessionsFeedbacks < ActiveRecord::Migration
  def change
    create_table :sessions_feedbacks do |t|
      t.references :session_request, index: true
      t.references :by_user, index: true
      t.references :for_user, index: true
      t.text :message

      t.timestamps
    end
  end
end
