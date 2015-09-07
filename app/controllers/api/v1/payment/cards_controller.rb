class Api::V1::Payment::CardsController < Api::V1::PaymentController

  resource_description do
    name 'User Payment Cards'
    short 'Methods for managing the user\'s cards used for the payments.'
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

  api :GET, '/payment/cards', 'Retrieve a list of cards associated with current user'
  def index
    cards = stripe_customer.sources.all(object: 'card')
    render json: cards.data
  end

  api :POST, '/payment/cards', 'Adds a new card to the current users'
  param :card, Hash, required: true do
    param :card, String, required: true, desc: 'The card token retorned by the Stripe servers'
  end
  def create
    card = stripe_customer.sources.create(create_card_params)
    render json: card
  end

  protected

  def create_card_params
    params.require(:card).permit(:card)
  end
end
