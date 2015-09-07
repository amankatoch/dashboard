class Api::V1::Payment::SubscriptionsController < Api::V1::PaymentController

  resource_description do
    name 'User Payment Subscriptions'
    short 'Methods for managing the user\'s subscriptions.'
    formats ['json']
    error 401, 'Unauthorized access'
    error 404, 'The requested resource was not found'
    error 406, 'Requested representation not available for the resource'
    error 422, 'Invalid data provided. Check that the params are valid'
    error 500, 'Internal server error.'
    error 503, 'Internal server error.'
    description <<-EOS

    EOS
  end

  api :GET, '/payment/subscriptions', 'Retrieve a user\'s subscriptions'
  def index
    subscriptions = stripe_customer.subscriptions
    render json: subscriptions.map { |s| s.to_hash }
  end

  api :POST, '/payment/subscriptions', 'Creates a new subscription on the current user'
  param :source, String, required: false, desc: 'The source for the payment. Required if the user '\
                                                'doesn\'t have a card associated and the subscription is not free'
  def create
    subscription = stripe_customer.subscriptions.create(
      plan: '7memfee',
      source: params[:source])
    render json: subscription.to_hash
  end

  protected

  def create_card_params
    params.require(:card).permit(:card)
  end
end
