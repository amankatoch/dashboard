class UserBalanceSerializer < ActiveModel::Serializer
  attributes :available, :pending

  def available
    object.available_balance
  end

  def pending
    object.pending_balance
  end
end
