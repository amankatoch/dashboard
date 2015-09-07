FactoryGirl.define do
  factory :user_favorite do
    association(:user)
    association(:favorite)
    sequence(:ordering)
  end
end