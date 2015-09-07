class SessionRequestSerializer < ActiveModel::Serializer
  attributes :id, :invited_user, :message, :status, :accepted_rejected_at,
             :location, :locations, :accepted_locations, :invited_user_comment,
             :created_at, :payment

  has_many :days

  def invited_user
    if object.invited_user
      { id: object.invited_user_id,
        name: object.invited_user.name,
        photo_public_id: object.invited_user.profile.photo_public_id,
        profile: object.invited_user.profile }
    else
      { id: object.user_id,
        name: object.user.name,
        photo_public_id: object.user.profile.photo_public_id,
        profile: object.user.profile }
    end
  end
end
