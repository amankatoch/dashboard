FactoryGirl.define do
  factory :profile do
    name { Faker::Name.name }
    gender 'm'
    age 30
    level 1
    location 'Boston'
    lat '1.111'
    lng '-1.321'
    about 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.'
    hourly_rate 5.99
  end
end