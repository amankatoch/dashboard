require 'rails_helper'

RSpec.describe User, :type => :model do
  let(:user) { create(:user, device_tokens: [build(:device_token, token: '1234')]) }
  let(:some_user) { create(:user) }

  it 'should enqueue a job for sending the push notification' do
    expect(Resque).to receive(:enqueue).with(ApnJob, '1234', 'this is a test', { 'badge' => 1 })

    user.send_push_notification(
      alert: 'this is a test',
      user: some_user)
  end

  it 'should create a new notification for the user' do
    expect(Resque).to receive(:enqueue).with(ApnJob, '1234', 'this is a test', { 'badge' => 1 })
    expect do
      user.send_push_notification(
        alert: 'this is a test',
        user: some_user)
    end.to change(user.notifications, :count).by(1)
    notification = Notification.last
    expect(notification.related_user).to eql(some_user)
    expect(notification.title).to eql('this is a test')
  end

  describe 'known_locations' do
    let(:user) { create(:user) }

    it 'returns any locations he has accepted' do
      create(:session_request, invited_user: user, status: 'accepted',
                               days: [create(:session_request_day, accepted: true)],
                               accepted_locations: ['Location XYZ', 'Other Location'])
      expect(user.known_locations).to eql ['Location XYZ', 'Other Location']
    end

    it 'returns any locations he has suggested' do
      create(:session_request, user: user, status: 'waiting',
                               days: [create(:session_request_day)],
                               locations: ['Location XYZ', 'Other Location'])
      expect(user.known_locations).to eql ['Location XYZ', 'Other Location']
    end

    it 'does not return duplicated rows' do
      create(:session_request, user: user, status: 'waiting',
                               days: [create(:session_request_day)],
                               locations: ['Location XYZ', 'Other Location'])

      create(:session_request, user: user, status: 'waiting',
                               days: [create(:session_request_day)],
                               locations: ['Location ABC', 'Other Location'])

      create(:session_request, invited_user: user, status: 'accepted',
                               days: [create(:session_request_day, accepted: true)],
                               accepted_locations: ['Location XYZ', 'Other Location', 'Cool Location'])

      expect(user.known_locations).to eql [
        'Cool Location', 'Location ABC', 'Location XYZ', 'Other Location']
    end

    it 'doesnt return suggested locations for matches he did not started' do
      create(:session_request, invited_user: user, status: 'waiting',
                               days: [create(:session_request_day)],
                               locations: ['Location XYZ', 'Other Location'])
      expect(user.known_locations).to be_empty
    end
  end
end
