FactoryGirl.define do
  factory :api_token do
    sequence(:name) { |n| "Test Token #{n}" }
    sequence(:token) { |n| "TestTokenSuperSecret#{n}" }
  end
end