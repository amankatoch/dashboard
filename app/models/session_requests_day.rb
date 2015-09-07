class SessionRequestsDay < ActiveRecord::Base
  belongs_to :session_request

  scope :accepted, -> { where(accepted: true) }

  scope :confirmed, -> { where(confirmed: true) }
end
