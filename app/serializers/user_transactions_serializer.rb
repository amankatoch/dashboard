class UserTransactionsSerializer < ActiveModel::Serializer

  attributes :id, :created_at, :updated_at, :amount, :status, :action, :source, :user
  has_one :session_request

  def action
    if object.session_request.invited_user_id == scope[:current_user].id
      :received
    else
      :sent
    end
  end

  def source
    return if object.session_request.invited_user_id == scope[:current_user].id
    charge = Stripe::Charge.retrieve(object.stripe_charge_id)
    {
      last4: charge.source.last4,
      # type: charge.source.type,
      brand: charge.source.brand,
      funding: charge.source.funding
    }
  end

  def user
    { name: object.session_request.invited_user.name,
      photo_public_id: object.session_request.invited_user.profile.photo_public_id }
  end
end
