class Payment < ActiveRecord::Base
  belongs_to :session_request

  enum status: {
    waiting:   0, # Waiting for users feedback before assigning it to the user
    completed: 1, # Feedback given and can be counted in user's balance
    payed:  2     # This have been payed to the user
  }

  attr_accessor :source

  before_create :perform_charge

  def self.related_to(user)
    joins(:session_request)
      .where('session_requests.invited_user_id = :id OR session_requests.user_id = :id',
             id: user.id)
  end

  protected

  def perform_charge
    charge = session_request.user.stripe_charge(
      source: source,
      amount: (amount*100).to_i,
      currency: 'usd'
    )
    self.stripe_charge_id = charge.id
    self.status = 0
    true
    rescue Stripe::InvalidRequestError => e
      Rails.logger.debug e.inspect
      return false
  end
end
