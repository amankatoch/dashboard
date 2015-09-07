class SessionsFeedback < ActiveRecord::Base
  belongs_to :session_request
  belongs_to :by_user, class: User
  belongs_to :for_user, class: User

  has_many :sessions_feedbacks_skills
  has_many :skills, through: :sessions_feedbacks_skills

  validates :session_request, presence: true
  validates :by_user, presence: true
  validates :for_user, presence: true
  validates :for_user_id,
            inclusion: { in: ->(r) { [r.session_request.user_id, r.session_request.invited_user_id] } },
            if: :session_request
  validates :by_user_id,
            inclusion: { in: ->(r) { [r.session_request.user_id, r.session_request.invited_user_id] } },
            if: :session_request

  validate :valid_users

  after_create :update_session_payment

  protected

  def valid_users
    return unless by_user.present? && for_user.present?
    errors.add :by_user, 'cannot be the same as for_user' if by_user_id == for_user_id
  end

  def update_session_payment
    return unless session_request.payment.present?
    session_request.payment.completed!
  end
end
