class SessionRequest < ActiveRecord::Base
  belongs_to :invited_user, class_name: 'User'
  belongs_to :user

  has_many :days, class_name: 'SessionRequestsDay',
                  inverse_of: :session_request, dependent: :destroy

  has_many :sessions_feedbacks, dependent: :destroy
  has_one :payment

  accepts_nested_attributes_for :days
  accepts_nested_attributes_for :payment, reject_if: proc { |payment| payment['id'].present? }

  validates :user, presence: true
  validates :payment, presence: true, if: :payment_required?

  validate :user_not_same
  validate :status_transition
  validate :valid_days?
  validate :valid_payment_information?

  after_create :new_session_notification

  after_save :session_request_accepted

  enum status: { waiting: 0, accepted: 1, rejected: 2, confirmed: 3 }

  scope :for_user, ->(user) { where('session_requests.user_id=:user_id OR session_requests.invited_user_id = :user_id OR session_requests.invited_user_id IS NULL', user_id: user.id) }

  protected

  def user_not_same
    errors.add :user_id, 'cannot be the same user' if user_id == invited_user_id
  end

  def status_transition
    errors.add :status, 'cannot be changed' if status_changed? && status == 'rejected'  && status_was == 'accepted'
    errors.add :status, 'cannot be changed' if status_changed? && ['rejected', 'confirmed'].include?(status_was)
  end

  def new_session_notification
    invited_user.send_push_notification(
      alert: "#{user.name} has invited you to play a match.") unless not invited_user
  end

  def session_request_accepted
    return unless status_changed?
    if accepted?
      user.send_push_notification(
        alert: "#{invited_user.name} has accepted your invitation",
        user: invited_user)
    elsif confirmed?
      invited_user.send_push_notification(
        alert: "#{user.name} has confirmed the match",
        user: user)
    elsif rejected?
      user.send_push_notification(
        alert: "Sadly, #{invited_user.name} has rejected your invitation",
        user: invited_user)
    end
  end

  def valid_days?
    validate_accepted_days if status == 'accepted'
    validate_suggested_days if new_record? and invited_user
  end

  def validate_accepted_days
    return if days.any?(&:accepted?)
    errors.add(:status, 'cannot accept without accepting at least one day')
  end

  def validate_suggested_days
    return if days.any?
    errors.add(:status, 'cannot invite without suggesting days')
  end

  # Checks if the session request can be created without a payment information
  # and if the payment is valid
  def valid_payment_information?
    return true if not invited_user or invited_user.profile.level <= user.profile.level
    errors.add :user_id, 'does not have a valid subscription' unless user.valid_subscription?
  end

  def payment_required?
    return false if user.nil? || invited_user.nil?
    user.profile.level < invited_user.profile.level
  end
end
