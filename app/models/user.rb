class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  has_one :profile, dependent: :destroy

  has_many :device_tokens
  has_many :user_favorites, -> { order 'user_favorites.ordering ASC' }, dependent: :destroy
  has_many :session_requests, -> { order 'session_requests.created_at ASC' },
           inverse_of: :user, dependent: :destroy
  has_many :session_invitations, -> { order 'session_requests.created_at ASC' },
           foreign_key: :invited_user_id, class: SessionRequest, inverse_of: :invited_user,
           dependent: :destroy
  has_many :notifications, -> { order 'notifications.created_at ASC' },
           inverse_of: :user, dependent: :destroy

  has_many :favorited, dependent: :destroy, class_name: 'UserFavorite', foreign_key: :favorite_id
  has_many :payments, through: :session_invitations

  accepts_nested_attributes_for :profile

  delegate :name, to: :profile, allow_nil: true

  def ensure_authentication_token
    self.authentication_token = generate_authentication_token if authentication_token.blank?
  end

  def active_for_authentication?
    true
  end

  def reset_authentication_token!
    self.authentication_token = nil
    ensure_authentication_token
    save validate: false
  end

  def send_push_notification(alert: nil, user: nil)
    notifications.create(title: alert, related_user: user)
    device_tokens.apple.each do |device|
      Resque.enqueue ApnJob, device.token, alert, 'badge' => notifications.unread.count
    end
  end

  def known_locations
    self.class.connection.unprepared_statement do
      self.class.connection.select_values(
        session_invitations.select('unnest(accepted_locations)').reorder(nil).to_sql +
        ' UNION ' +
        session_requests.select('unnest(locations)').reorder(nil).to_sql +
        ' ORDER by 1'
      )
    end
  end

  def self.location_near(loc)
    (lat, lng, radius) = loc.split(/\s*,\s*/)
    joins(:profile)
      .where("profiles.id in (#{Profile.select(:id).within_box(radius.to_i, lat.to_f, lng.to_f).to_sql})")
  end

  def self.ransackable_scopes(_ = nil)
    %i(location_near)
  end

  def stripe_customer
    @stripe_customer ||= Stripe::Customer.retrieve(stripe_customer_id) unless stripe_customer_id.nil?
  end

  def stripe_recipient
    @stripe_recipient ||= Stripe::Recipient.retrieve(stripe_recipient_id) unless stripe_recipient_id.nil?
  end

  def active_subscription
    stripe_customer.subscriptions.data.find do |subscription|
      subscription.active && subscription.canceled_at.nil?
    end
  end

  def valid_subscription?
    stripe_customer.present? && stripe_customer.subscriptions.all.data.detect{|s| s.status == 'active' }
  end

  def stripe_charge(params)
    if params[:source]
      Stripe::Charge.create params
    else
      Stripe::Charge.create params.merge(customer: stripe_customer_id)
    end
  end

  def ensure_stripe_customer!
    return if stripe_customer.present?
    customer = Stripe::Customer.create(
      description: profile.name,
      email: email
    )
    update_attribute(:stripe_customer_id, customer.id)
  end

  def ensure_stripe_recipient!
    return if stripe_recipient.present?
    recipient = Stripe::Recipient.create(
      name: profile.name,
      type: 'individual'
    )
    update_attribute(:stripe_recipient_id, recipient.id)
  end

  def self.find_or_create_from_facebook_token(token)
    graph = Koala::Facebook::API.new(token)
    fb_user = graph.get_object("me")
    user = find_by(facebook_id: fb_user["uid"])
    return user if user.present?
    create_with(profile_attributes: { name: fb_user.name }).find_or_create_by(email: fb_user.email)
  end

  def pending_balance
    payments.where(status: 0).sum(:amount)
  end

  def available_balance
    available_payments.sum(:amount)
  end

  def available_payments
    payments.where(status: 1 )
  end

  def withdraw_balance
    return false unless can_receive_transfer?
    amount = available_balance
    return false unless amount > 0
    transfer = Stripe::Transfer.create(
      :amount => amount,
      :currency => 'usd',
      :recipient => stripe_recipient_id,
      :description => 'Transfer from balance at PracticeGigs'
    )
    available_payments.update_all(
      status: 2,
      transferred_at: Time.now,
      transfer_id: transfer.id)
  end

  def can_receive_transfer?
    stripe_recipient_id.present? && stripe_recipient.cards['total_count'] > 0
  end

  protected

  def password_required?
   !persisted? || !password.blank? || !password_confirmation.blank?
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless self.class.where(authentication_token: token).first
    end
  end
end
