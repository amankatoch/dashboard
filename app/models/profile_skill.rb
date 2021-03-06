class ProfileSkill < ActiveRecord::Base
  belongs_to :profile
  belongs_to :skill

  validates :skill_id, uniqueness: { scope: :profile_id }
end
