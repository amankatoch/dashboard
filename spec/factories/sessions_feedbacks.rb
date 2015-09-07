FactoryGirl.define do
  factory :sessions_feedback do
    session_request nil
    by_user_id nil
    for_user_id nil
    message "MyText"
  end

end
