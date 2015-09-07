FactoryGirl.define do
  factory :session_request do
    association :user
    association :invited_user, factory: :user
    message { Faker::Lorem.sentence }
    status 'waiting'
    accepted_rejected_at nil
  end
end
