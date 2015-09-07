FactoryGirl.define do
  factory :skill do
    sequence(:name) { |n| "Test Skill #{n}" }
  end
end