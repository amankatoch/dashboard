require 'rails_helper'

RSpec.describe Api::V1::SessionInvitationsController, :type => :controller do
  let(:user) { create(:user) }

  describe 'with valid credentials' do
    before { set_api_authentication_headers user }

    describe 'GET index' do
      it 'creates a new request for :invited_user', show_in_doc: true do
        create(:session_request, invited_user: user, days: [
          build(:session_request_day, date: 1.week.from_now.to_date.to_s(:slashes),
                                      time_start: '08:00 AM', time_end: '11:00 AM'),
          build(:session_request_day, date: 1.week.from_now.to_date.to_s(:slashes),
                                      time_start: '08:00 PM', time_end: '10:00 PM'),
          build(:session_request_day, date: 9.days.from_now.to_date.to_s(:slashes),
                                      time_start: '06:00 PM', time_end: '09:00 PM')
        ])
        create(:session_request, invited_user: user, days: [
          build(:session_request_day, date: Date.tomorrow.to_s(:slashes),
                                      time_start: '08:00 AM', time_end: '11:00 AM')
        ])
        get :index, format: :json
        expect(response).to be_success

        expect(json.count).to eql 2

        expect(json.first.keys).to match_array %w(
          id user message days locations status accepted_rejected_at created_at)
      end
    end

    describe 'PUT update' do
      it 'accepts the invitation', show_in_doc: true do
        invitation = create(:session_request,
                            invited_user: user, locations: ['Arena Stadium', 'SF Country Club'],
                            days: [
                              build(:session_request_day, date: 1.week.from_now.to_date.to_s(:slashes),
                                                          time_start: '08:00 AM', time_end: '03:00 PM')
                            ])
        put :update, format: :json, id: invitation.id,
                     session_invitation: {
                       comment: 'Ok, let\'s do it!',
                       status: 'accepted',
                       locations: ['SF Country Club'],
                       days_attributes: [
                         { id: invitation.days.first.id,
                           time_start: '09:00 AM',
                           time_end: '10:00 AM',
                           accepted: true }] }
        expect(response.code).to eql '204'

        expect(invitation.reload.status).to eql 'accepted'
        expect(invitation.invited_user_comment).to eql 'Ok, let\'s do it!'
        expect(invitation.accepted_locations).to eql ['SF Country Club']
        day = invitation.days.first.reload
        expect(day.accepted).to be_truthy
        expect(day.accepted_time_start.to_s(:ampm)).to eql '09:00 AM'
        expect(day.accepted_time_end.to_s(:ampm)).to eql '10:00 AM'
      end

      it 'accepts the invitation' do
        invitation = create(:session_request, invited_user: user, days: [
          build(:session_request_day, date: 1.week.from_now.to_date.to_s(:slashes),
                                      time_start: '08:00 AM', time_end: '11:00 AM')
        ])
        put :update, format: :json, id: invitation.id,
                     session_invitation: { status: 'rejected' }
        expect(response.code).to eql '204'

        expect(invitation.reload.status).to eql 'rejected'
      end

      it 'cannot accept an invitation sent to another user' do
        invitation = create(:session_request, status: 'waiting', days: [
          build(:session_request_day, date: 1.week.from_now.to_date.to_s(:slashes),
                                      time_start: '08:00 AM', time_end: '11:00 AM')
        ])
        put :update, format: :json, id: invitation.id, session_invitation: { status: 'accepted' }
        expect(response.code).to eql '404'
        expect(invitation.reload.status).to eql 'waiting'
      end

      it 'cannot rejected a accepted invitiation' do
        invitation = create(:session_request, invited_user: user, status: 'accepted', days: [
          build(:session_request_day, date: 1.week.from_now.to_date.to_s(:slashes), accepted: true,
                                      time_start: '08:00 AM', time_end: '11:00 AM')
        ])
        put :update, format: :json, id: invitation.id, session_invitation: { status: 'rejected' }
        expect(response.code).to eql '422'
        expect(invitation.reload.status).to eql 'accepted'
      end

      it 'cannot accept an invitiation without accepting at least one day' do
        invitation = create(:session_request, invited_user: user, status: 'waiting', days: [
          build(:session_request_day, date: 1.week.from_now.to_date.to_s(:slashes),
                                      time_start: '08:00 AM', time_end: '11:00 AM')
        ])
        put :update, format: :json, id: invitation.id,
                     session_invitation: {
                       comment: 'Ok, let\'s do it!',
                       status: 'accepted',
                       days_attributes: [
                         { id: invitation.days.first.id, accepted: false }] }
        expect(response.code).to eql '422'
        expect(invitation.reload.status).to eql 'waiting'
        expect(json).to eql(
          'errors' => { 'status' => [
            'cannot accept without accepting at least one day'] })
      end
    end

    describe 'POST feedback' do
      let(:user_inviting) { create(:user) }
      let(:session_request) do
        create(:session_request,
               user: user_inviting, invited_user: user,
               days: [ build(:session_request_day) ])
      end

      it 'creates a feedback record for the session request', show_in_doc: true do
        skill = create(:skill)
        expect do
          post :feedback, id: session_request.id, format: :json, feedback: {
            message: 'it was fun!',
            skill_ids: [skill.id]
          }
        end.to change(SessionsFeedback, :count).by(1)
        session_feedback = SessionsFeedback.last
        expect(session_feedback.by_user).to eql user_inviting
        expect(session_feedback.for_user).to eql user
        expect(session_feedback.skills.to_a).to eql [skill]
        expect(session_feedback.message).to eql 'it was fun!'
      end
    end
  end
end
