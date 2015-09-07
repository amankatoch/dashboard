require 'rails_helper'

RSpec.describe SessionRequest, type: :model do
  describe 'session_request_accepted callback' do

    let(:user) { create(:user) }
    let(:invited_user) { create(:user) }

    it 'requires a payment if the invited user\'s level is greater than mine' do
      user.profile.update_attribute(:level, 1)
      invited_user.profile.update_attribute(:level, 2)
      session = build(:session_request, user: user, invited_user: invited_user,
                                         days: [build(:session_request_day)])
      expect(session.valid?).to be_falsey
      expect(session.errors.full_messages).to include("Payment can't be blank")
    end

    it 'does not send the notification when creating a session request' do
      expect(user).not_to receive(:send_push_notification)
      create(:session_request, user: user, invited_user: invited_user,
                               days: [build(:session_request_day)])
    end

    it 'sends the notification when user accepts the invitation' do
      request = create(:session_request,
                        user: user, invited_user: invited_user,
                        days: [build(:session_request_day)])

      expect(request.user).to receive(:send_push_notification).with(
        alert: "#{invited_user.name} has accepted your invitation",
        user: an_instance_of(User)
      )
      request.update_attributes(
        status: :accepted,
        message: 'ok!',
        days_attributes: [ { id: request.days.first.id, accepted: true } ])
    end

    it 'sends the notification when user rejects the invitation' do
      request = create(:session_request,
                        user: user, invited_user: invited_user,
                        days: [build(:session_request_day)])

      expect(request.user).to receive(:send_push_notification).with(
        alert: "Sadly, #{invited_user.name} has rejected your invitation",
        user: an_instance_of(User)
      )
      request.update_attributes(
        status: :rejected,
        message: 'Sorry, I have to study!',
        days_attributes: [ { id: request.days.first.id, accepted: false } ])
    end
  end
end
