require 'stripe'
Stripe.api_key = 'sk_test_EMMEbP1U6KDfqezdVzW6WAQ4'

class Api::V1::PaymentController < Api::V1::ApiController

  class MissingStripCustomer  < StandardError
  end

  before_action :ensure_stripe_customer

  before_action do
    fail MissingStripCustomer unless stripe_customer.present?
  end

  rescue_from MissingStripCustomer, :with => :missing_stripe_customer

  protected

  def ensure_stripe_customer
    current_user.ensure_stripe_customer!
  end

  def missing_stripe_customer
    render :status => 503,
           :json => { :message => "The user doesn't have a stripe customer associated" }
  end

  def stripe_customer
    current_user.stripe_customer
  end
end
