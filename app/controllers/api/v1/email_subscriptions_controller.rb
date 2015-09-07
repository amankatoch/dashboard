class Api::V1::EmailSubscriptionsController < Api::V1::ApiController
  inherit_resources

  skip_before_action :authenticate_user_from_token!

  defaults resource_class: Subscription

  actions :create

  resource_description do
    name 'Email Subscriptions'
    short 'Email suscriptions'
    formats ['json']
    error 200, "No error, operation successful."
    error 201, "No error, user created."
    error 204, "The request was processed successfully, but no response body is needed."
    error 401, "Unauthorized access"
    error 404, "The requested resource was not found"
    error 406, "Requested representation not available for the resource"
    error 422, "Invalid data provided. Check that the params are valid"
    error 500, "Internal server error."
    description <<-EOS

    EOS
  end

  def_param_group :email_subscription do
    param :email_subscription, Hash, required: true, action_aware: true do
      param :email, String, required: true, desc: 'The users email'
    end
  end

  api :POST, '/subscriptions', "Register a new subscription"
  param_group :email_subscription
  def create
    create!
  end

  protected

  def email_subscription_params
    params.require(:email_subscription).permit(:email)
  end
end
