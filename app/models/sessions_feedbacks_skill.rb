class SessionsFeedbacksSkill < ActiveRecord::Base
  belongs_to :skill
  belongs_to :sessions_feedback
end
