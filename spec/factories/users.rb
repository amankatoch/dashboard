FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| Faker::Internet.email(profile.name) }
    password 'Changeme123'
    password_confirmation 'Changeme123'

    association(:profile)

    before(:create) do |user|
      user.ensure_authentication_token
    end
  end
end