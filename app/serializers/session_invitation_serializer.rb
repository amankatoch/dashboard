class SessionInvitationSerializer < ActiveModel::Serializer
  attributes :id, :user, :message, :status, :accepted_rejected_at,
             :locations, :created_at, :payment

  has_many :days

  def user
    { id: object.user_id,
      name: object.user.name,
      photo_public_id: object.user.profile.photo_public_id,
      profile: object.user.profile }
  end
end
