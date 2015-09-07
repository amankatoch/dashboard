require 'rails_helper'

RSpec.describe Api::V1::SessionRequestsController, type: :controller do
  let(:user) { create(:user) }

  let(:stripe_helper) { StripeMock.create_test_helper }

  describe 'with valid credentials' do
    before { set_api_authentication_headers user }

    describe 'POST create' do
      let(:invited_user) { create(:user) }

      it 'creates a new request for :invited_user', show_in_doc: true do
        expect do
          post :create, format: :json, session_request: {
            invited_user_id: invited_user.id,
            message: 'I will kick your ass!',
            locations: ['Kolbi Arena', 'Costa Rica Country Club'],
            days_attributes: [
              { date: 1.week.from_now.to_date.to_s(:slashes), time_start: '08:00 AM', time_end: '11:00 AM' },
              { date: 1.week.from_now.to_date.to_s(:slashes), time_start: '08:00 PM', time_end: '10:00 PM' },
              { date: 9.days.from_now.to_date.to_s(:slashes), time_start: '06:00 PM', time_end: '09:00 PM' }
            ]
          }
        end.to change(SessionRequest, :count).by(1)
        session_request = SessionRequest.last
        expect(session_request.user).to eql user
        expect(session_request.invited_user).to eql invited_user

        expect(session_request.locations).to match_array [
          'Kolbi Arena', 'Costa Rica Country Club']

        expect(session_request.days.count).to eql 3

        expect(json['days'].map { |d| d['time_start'] }).to match_array [
          '08:00 AM', '08:00 PM', '06:00 PM'
        ]
        expect(json['days'].map { |d| d['time_end'] }).to match_array [
          '11:00 AM', '10:00 PM', '09:00 PM'
        ]
      end

      it 'fails if not days were suggested' do
        expect do
          post :create, format: :json, session_request: {
            invited_user_id: invited_user.id,
            message: 'I will kick your ass!',
            days_attributes: []
          }
        end.not_to change(SessionRequest, :count)
        expect(response.code).to eql '422'
        expect(json).to eql(
          'errors' => { 'status' => [
            'cannot invite without suggesting days'] })
      end

      describe 'when invited user is a higher level' do
        before { StripeMock.start }
        after { StripeMock.stop }

        before { invited_user.profile.update_attribute(:level, 5) }

        let(:session_information) do
          {
            invited_user_id: invited_user.id,
            message: 'I will kick your ass!',
            locations: ['Kolbi Arena', 'Costa Rica Country Club'],
            days_attributes: [
              { date: 1.week.from_now.to_date.to_s(:slashes), time_start: '08:00 AM', time_end: '11:00 AM' },
              { date: 1.week.from_now.to_date.to_s(:slashes), time_start: '08:00 PM', time_end: '10:00 PM' },
              { date: 9.days.from_now.to_date.to_s(:slashes), time_start: '06:00 PM', time_end: '09:00 PM' }
            ]
          }
        end

        it 'fails if no payment information is sent' do
          expect do
            post :create, format: :json, session_request: session_information
          end.to_not change(SessionRequest, :count)
          expect(response.code).to eql '422'
        end

        describe 'with valid subscription' do
          it 'it succeeds with valid payment information' do
            Settings.find_or_create_by(key: 'stripe_subscription_plan', value: 'some_plan')
            plan = stripe_helper.create_plan(id: Settings.stripe_subscription_plan, amount: 1500)
            user.ensure_stripe_customer!
            user.stripe_customer.subscriptions.create(plan: plan.id, source: stripe_helper.generate_card_token)

            expect do
              expect do
                post :create, format: :json, session_request: session_information.merge(
                  payment_attributes: {
                    source: stripe_helper.generate_card_token,
                    amount: 100.5
                  }
                )
              end.to change(SessionRequest, :count).by(1)
            end.to change(Payment, :count).by(1)
            expect(response.code).to eql '201'
            payment = Payment.last
            expect(payment.session_request_id).to eql json['id']
            expect(payment.stripe_charge_id).to_not be_empty
            expect(payment.amount).to eql 100.5
            expect(payment.waiting?).to be_truthy
          end
        end
      end
    end

    describe 'PUT update' do
      it 'confirms a request', show_in_doc: true do
        session_request = create(:session_request,
                            user: user,
                            status: 'accepted',
                            locations: ['Arena Stadium', 'SF Country Club'],
                            accepted_locations: ['Arena Stadium', 'SF Country Club'],
                            days: [
                              build(:session_request_day, date: 1.week.from_now.to_date.to_s(:slashes),
                                                          accepted: true,
                                                          time_start: '08:00 AM', time_end: '03:00 PM')
                            ])
        put :update, format: :json, id: session_request.id,
                     session_request: {
                       status: 'confirmed',
                       location: 'SF Country Club',
                       days_attributes: [
                         { id: session_request.days.first.id,
                           confirmed: true }] }
        expect(response.code).to eql '204'

        expect(session_request.reload.status).to eql 'confirmed'
        expect(session_request.location).to eql 'SF Country Club'
        day = session_request.days.first.reload
        expect(day.confirmed).to be_truthy
      end
    end

    describe 'POST feedback' do
      let(:invited_user) { create(:user) }
      let(:skill) { create(:skill) }
      let(:session_request) do
        create(:session_request,
               user: user, invited_user: invited_user,
               days: [ build(:session_request_day) ])
      end

      it 'creates a feedback record for the session request', show_in_doc: true do
        expect do
          post :feedback, id: session_request.id, format: :json, feedback: {
            message: 'it was fun!',
            skill_ids: [skill.id]
          }
        end.to change(SessionsFeedback, :count).by(1)
        session_feedback = SessionsFeedback.last
        expect(session_feedback.by_user).to eql user
        expect(session_feedback.for_user).to eql invited_user
        expect(session_feedback.skills.to_a).to eql [skill]
        expect(session_feedback.message).to eql 'it was fun!'
      end

      describe 'payment management' do
        before { StripeMock.start }
        after { StripeMock.stop }

        let(:stripe_helper) { StripeMock.create_test_helper }

        it 'marks the payment as completed' do
          payment = session_request.create_payment(amount: 100, source: stripe_helper.generate_card_token)
          expect(payment.status).to eql 'waiting'
          post :feedback, id: session_request.id, format: :json, feedback: {
            message: 'it was fun!',
            skill_ids: [skill.id]
          }
          expect(payment.reload.status).to eql 'completed'
        end
      end
    end

    describe 'GET index' do
      it 'creates a new request for :invited_user', show_in_doc: true do
        create(:session_request, user: user, days: [
          build(:session_request_day, date: 1.week.from_now.to_date.to_s(:slashes), time_start: '08:00 AM', time_end: '11:00 AM'),
          build(:session_request_day, date: 1.week.from_now.to_date.to_s(:slashes), time_start: '08:00 PM', time_end: '10:00 PM'),
          build(:session_request_day, date: 9.days.from_now.to_date.to_s(:slashes), time_start: '06:00 PM', time_end: '09:00 PM')
        ])
        create(:session_request,
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
        get :index, format: :json
        expect(response).to be_success

        expect(json.count).to eql 2

        expect(json.first.keys).to match_array %w(
          id invited_user message days status invited_user_comment location
          locations accepted_locations accepted_rejected_at created_at)
      end
    end
  end
end
