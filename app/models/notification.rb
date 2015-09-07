class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :related_user, class_name: 'User'

  validates :user, presence: true
  validates :title, presence: true

  enum status: { unread: 0, read: 1, trashed: 2 }
end
