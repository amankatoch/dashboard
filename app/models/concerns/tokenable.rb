module Tokenable
  extend ActiveSupport::Concern

  included do
    before_validation :generate_token
  end

  protected

  def generate_token
    self.token ||= loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless self.class.exists?(token: random_token)
    end
  end
end