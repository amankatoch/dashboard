class DeviseResqueMailer < Devise::Mailer
  include Resque::Mailer

  default from: "help@practicegigs.com"
end
