class ApiToken < ActiveRecord::Base
  include Tokenable

  validates :name, presence: true
  validates :token, presence: true,
    uniqueness: true, length: 16..255
end
