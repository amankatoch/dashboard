class UserFavoriteSerializer < ActiveModel::Serializer
  attributes :id, :ordering

  has_one :favorite
end
