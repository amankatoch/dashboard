require 'rails_helper'

RSpec.describe Api::V1::Payment::BalanceController, type: :controller do
  let(:user) { create(:user) }
  let(:stripe_helper) { StripeMock.create_test_helper }

  before { StripeMock.start }
  after { StripeMock.stop }

  before { set_api_authentication_headers user }

  describe 'GET index' do
    it 'returns the balance at zero' do
      get :index, format: :json
      expect(json).to eql({ 'available' => 0.0, 'pending' => 0.0 })
    end

    it 'returns the correct balance based on the user received payments', :show_in_doc do

      # Session request without feedback
      session_request = create(:session_request,
        invited_user: user, invited_user_comment: 'it will be fun!', status: 'accepted',
        locations: ['SF Country Club', 'Arena Tennis Club'],
        accepted_locations: ['SF Country Club'],
        days: [
          build(:session_request_day, date: Date.tomorrow.to_s(:slashes),
                                      accepted: true,
                                      time_start: '08:00 AM', time_end: '11:00 AM',
                                      accepted_time_start: '08:00 AM',
                                      accepted_time_end: '10:00 AM')
      ])
      create(:payment, session_request: session_request,  amount: 15.45,
                       source: stripe_helper.generate_card_token)

      # Session request with feedback
      session_request = create(:session_request,
        invited_user: user, invited_user_comment: 'it will be fun!', status: 'accepted',
        locations: ['SF Country Club', 'Arena Tennis Club'],
        accepted_locations: ['SF Country Club'],
        days: [
          build(:session_request_day, date: Date.tomorrow.to_s(:slashes),
                                      accepted: true,
                                      time_start: '08:00 AM', time_end: '11:00 AM',
                                      accepted_time_start: '08:00 AM',
                                      accepted_time_end: '10:00 AM')
      ])
      create(:sessions_feedback, session_request: session_request,
                                 by_user: session_request.user,
                                 for_user: session_request.invited_user)
      create(:payment, session_request: session_request,  amount: 13.44,
                       source: stripe_helper.generate_card_token).completed!

      get :index, format: :json
      expect(json).to eql('available' => 13.44, 'pending' => 15.45)
    end
  end

  describe 'PUT withdraw' do
    it 'transfer the money to users credit card', :show_in_doc do
      # Session request with feedback
      session_request = create(:session_request,
        invited_user: user, invited_user_comment: 'it will be fun!', status: 'accepted',
        locations: ['SF Country Club', 'Arena Tennis Club'],
        accepted_locations: ['SF Country Club'],
        days: [
          build(:session_request_day, date: Date.tomorrow.to_s(:slashes),
                                      accepted: true,
                                      time_start: '08:00 AM', time_end: '11:00 AM',
                                      accepted_time_start: '08:00 AM',
                                      accepted_time_end: '10:00 AM')
      ])
      create(:sessions_feedback, session_request: session_request,
                                 by_user: session_request.user,
                                 for_user: session_request.invited_user)
      create(:payment, session_request: session_request,  amount: 13.44,
                       source: stripe_helper.generate_card_token).completed!

      recipient = Stripe::Recipient.create(
        name: user.profile.name,
        type: "individual",
        card: stripe_helper.generate_card_token
      )
      user.update_attribute(:stripe_recipient_id, recipient.id)

      put :withdraw, format: :json
      expect(response).to be_success
      payment = Payment.last
      expect(payment.reload.transfer_id).to_not be_empty
      expect(payment.reload.transferred_at.to_date).to eql Time.current.to_date
    end
  end

  describe 'GET transactions' do
    it 'returns sent and received transactions', :show_in_doc do

      # Payment received
      session_request = create(:session_request,
        invited_user: user, invited_user_comment: 'it will be fun!', status: 'accepted',
        locations: ['SF Country Club', 'Arena Tennis Club'],
        accepted_locations: ['SF Country Club'],
        days: [
          build(:session_request_day, date: Date.tomorrow.to_s(:slashes),
                                      accepted: true,
                                      time_start: '08:00 AM', time_end: '11:00 AM',
                                      accepted_time_start: '08:00 AM',
                                      accepted_time_end: '10:00 AM')
      ])
      create(:sessions_feedback, session_request: session_request,
                                 by_user: session_request.user,
                                 for_user: session_request.invited_user)
      p1 = create(:payment, session_request: session_request, amount: 13.44,
                            source: stripe_helper.generate_card_token)
      p1.completed!

      # Payment sent
      session_request = create(:session_request,
        user: user, invited_user_comment: 'it will be fun!', status: 'accepted',
        locations: ['SF Country Club', 'Arena Tennis Club'],
        accepted_locations: ['SF Country Club'],
        days: [
          build(:session_request_day, date: Date.tomorrow.to_s(:slashes),
                                      accepted: true,
                                      time_start: '08:00 AM', time_end: '11:00 AM',
                                      accepted_time_start: '08:00 AM',
                                      accepted_time_end: '10:00 AM')
      ])
      create(:sessions_feedback, session_request: session_request,
                                 by_user: session_request.invited_user,
                                 for_user: session_request.user)
      p2 = create(:payment, session_request: session_request, amount: 13.44,
                            source: stripe_helper.generate_card_token)
      p2.completed!

      get :transactions, format: :json
      expect(response).to be_success

      expect(json.first).to eql(
        { 'id' => p1.id, 'created_at' => p1.created_at.as_json, 'updated_at' => p1.updated_at.as_json,
          'amount' => 13.44, 'status' => 'completed', 'action' => 'received', 'source' => nil })

      expect(json.second).to include(
        { 'id' => p2.id, 'created_at' => p2.created_at.as_json, 'updated_at' => p2.updated_at.as_json,
          'amount' => 13.44, 'status' => 'completed', 'action' => 'sent' })
    end
  end

  describe 'POST credit_card' do
    pending 'transfer the money to users credit card', :show_in_doc do
      post :debit_card, card: stripe_helper.generate_card_token, format: :json
      expect(response).to be_success
      user.reload
      expect(user.stripe_recipient).to_not be_nil
      expect(user.stripe_recipient.cards.data.count).to eql 1
    end
  end

end
