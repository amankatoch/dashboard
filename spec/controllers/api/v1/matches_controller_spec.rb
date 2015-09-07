require 'rails_helper'

RSpec.describe Api::V1::MatchesController, :type => :controller do
  let(:user) { create(:user) }

  describe 'with valid credentials' do
    before { set_api_authentication_headers user }

    describe 'GET index' do
      it 'retrieve a list of matches for the given user', show_in_doc: true do
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

        create(:session_request,
                invited_user: user, status: 'confirmed', location: 'Chapel Hill Tennis Club',
                days: [
                  build(:session_request_day, date: 1.week.from_now.to_date.to_s(:slashes),
                                              time_start: '08:00 AM', time_end: '11:00 AM'),
                  build(:session_request_day, date: 1.week.from_now.to_date.to_s(:slashes),
                                              time_start: '07:00 PM', time_end: '11:00 PM',
                                              accepted_time_start: '08:00 PM', accepted_time_end: '10:00 PM',
                                              confirmed: true, accepted: true),
                  build(:session_request_day, date: 9.days.from_now.to_date.to_s(:slashes), time_start: '06:00 PM', time_end: '09:00 PM')
                ])

        get :index, format: :json
        expect(response).to be_success

        expect(json.count).to eql 3

        expect(json.first.keys).to match_array %w(
          session_request_id player message days status invited_user_comment
          locations initiated_by_me accepted_rejected_at created_at updated_at)

        expect(json.second['days']).to eql [{
          'date' => Date.tomorrow.to_s(:dashes),
          'time_start' => '08:00 AM',
          'time_end' => '10:00 AM'
        }]

        expect(json.first['days']).to eql [{
          'date' => 1.week.from_now.to_date.to_s(:dashes),
          'time_start' => '08:00 PM',
          'time_end' => '10:00 PM'
        }]

        expect(json.first['initiated_by_me']).to be_falsey
        expect(json.second['initiated_by_me']).to be_truthy
      end

      it 'filters the matches by status', show_in_doc: true do
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

        create(:session_request,
                user: user, status: 'confirmed', location: 'Chapel Hill Tennis Club',
                days: [
                  build(:session_request_day, date: 1.week.from_now.to_date.to_s(:slashes),
                                              time_start: '08:00 AM', time_end: '11:00 AM'),
                  build(:session_request_day, date: 1.week.from_now.to_date.to_s(:slashes),
                                              time_start: '07:00 PM', time_end: '11:00 PM',
                                              accepted_time_start: '08:00 PM', accepted_time_end: '10:00 PM',
                                              confirmed: true, accepted: true),
                  build(:session_request_day, date: 9.days.from_now.to_date.to_s(:slashes), time_start: '06:00 PM', time_end: '09:00 PM')
                ])

        get :index, format: :json, status_in: ['3']
        expect(response).to be_success

        expect(json.count).to eql 1
        expect(json.first['locations']).to eql ['Chapel Hill Tennis Club']
      end
    end
  end
end
