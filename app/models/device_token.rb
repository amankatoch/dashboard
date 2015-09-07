class DeviceToken < ActiveRecord::Base
  belongs_to :user

  validates :token, presence: true, length: { minimum: 2 }, uniqueness: { scope: :user_id }
  validates :device_type, presence: true, inclusion: { in: ['ios', 'android'] }

  scope :apple, -> { where device_type: :ios }

  before_create do
    DeviceToken.where(token: token).destroy_all
  end
end
