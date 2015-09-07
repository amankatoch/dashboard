class Api::V1::Payment::BalanceController < Api::V1::PaymentController
  resource_description do
    name 'User Balance'
    short 'Methods for managing the user\'s balance.'
    formats ['json']
    error 401, 'Unauthorized access'
    error 404, 'The requested resource was not found'
    error 406, 'Requested representation not available for the resource'
    error 422, 'Invalid data provided. Check that the params are valid'
    error 500, 'Internal server error.'
    description <<-EOS

    EOS
  end

  api :GET, '/payment/balance', 'Get the user\'s current balance'
  def index
    render json: current_user, serializer: UserBalanceSerializer
  end

  api :GET, '/payment/balance/transactions', 'Get the a list of transactions for the current user'
  def transactions
    payments = ::Payment.related_to(current_user).order('payments.created_at ASC')
    render json: payments, each_serializer: UserTransactionsSerializer,
           scope: { current_user: current_user }
  end

  api :PUT, '/payment/balance/withdraw', 'Withdraw user\'s available balance to a credit card'
  def withdraw
    if !current_user.can_receive_transfer?
      render status: 422,
             json: { message: 'User cannot receive payments, verify he have any debit cards associated' }
    elsif current_user.withdraw_balance
      render text: nil
    else
      render status: 500,
             json: { message: 'Payment could not be made' }
    end
  end

  api :POST, '/payment/balance/credit_card', 'Sets the user\' debit card to be used for payments'
  param :card, String, required: true, desc: 'The debit card token to be assigned to the current user'
  def debit_card
    current_user.ensure_stripe_recipient!
    current_user.stripe_recipient.card = params[:card]
    current_user.stripe_recipient.save
    render text: nil
  end
end
