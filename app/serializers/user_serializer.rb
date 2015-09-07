class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :confirmed, :matches_count, :stripe_customer_id

  has_one :profile

  def matches_count
    SessionRequest.confirmed.for_user(object).count
  end

  def confirmed
    object.confirmed?
  end
end
