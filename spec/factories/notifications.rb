FactoryGirl.define do
  factory :notification do
    user nil
    title 'MyString'
    message 'MyText'
    status 0
    category 'MyString'
  end
end
