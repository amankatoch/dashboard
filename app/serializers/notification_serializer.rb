class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :title, :status, :created_at, :user

  def user
    { id: object.related_user.id, name: object.related_user.name }
  end
end
