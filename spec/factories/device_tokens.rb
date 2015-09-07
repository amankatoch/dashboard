FactoryGirl.define do
  factory :device_token do
    sequence(:token) { |n| "TestTokenSuperSecret#{n}" }
    device_type "ios"
  end
end