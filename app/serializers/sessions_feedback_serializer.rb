class SessionsFeedbackSerializer < ActiveModel::Serializer
  attributes :message

  has_many :skills
end
