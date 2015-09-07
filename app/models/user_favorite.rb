class UserFavorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :favorite, class_name: 'User'

  validates :favorite_id, uniqueness: { scope: :user_id, message: 'is already in the favority list' }
  validates :user, presence: true
  validates :favorite, presence: true

  validate :favorite_not_user

  before_save :ensure_ordering
  after_commit :update_siblings_order

  protected

  def favorite_not_user
    return if favorite_id.nil?
    errors.add(:favorite_id, 'cannot be the same user') if favorite_id == user_id
  end

  def ensure_ordering
    return if self.ordering > 0
    p self.ordering
    self.ordering = (self.user.user_favorites.maximum(:ordering) || 0) + 1
  end

  def update_siblings_order
    i = ordering
    user.user_favorites.where('ordering >= ? and user_favorites.id <> ?', ordering, id).each do |favorite|
      i += 1
      favorite.update_column(:ordering, i)
    end
  end
end
