class AddInvitedUserCommentColumnToSessionRequests < ActiveRecord::Migration
  def change
    add_column :session_requests, :invited_user_comment, :text
  end
end
