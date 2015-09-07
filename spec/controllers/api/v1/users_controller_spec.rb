require 'rails_helper'

describe Api::V1::UsersController, type: :controller do
  let(:user) { create(:user) }

  describe 'with valid credentials' do
    before { set_api_authentication_headers user }

    describe 'GET index' do
      it 'returns the profile info', show_in_doc: true do
        user2 = create(:user)
        user2.profile.skills << create(:skill, name: 'Forehand')
        user2.profile.skills << create(:skill, name: 'Backhand')

        user2.profile.availabilities.create(day: 'mon', time: 'night')
        user2.profile.availabilities.create(day: 'tue', time: 'afternoon')

        get :index, format: :json
        expect(json.count).to eql 1
        expect(json.first).to eql({
          'id'=> user2.id,
          'email' => user2.email,
          'confirmed' => false,
          'matches_count' => 0,
          'stripe_customer_id' => nil,
          'profile' => {
            'name' => user2.profile.name,
            'age' => 30,
            'gender' => user2.profile.gender,
            'level' => '1.0',
            'location' => user2.profile.location,
            'photo_public_id' => nil,
            'about' => user2.profile.about,
            'hourly_rate' => 5.99,
            'availability' => [
              { 'day' => 'mon', 'time' => 'night' },
              { 'day' => 'tue', 'time' => 'afternoon' }],
            'skills' => user2.profile.skills.map { |s| { 'id' => s.id, 'name' => s.name } }
          }
        })
      end

      it 'allows to search by location' do
        other_user = create(:user)
        other_user.profile.update_attributes(
          lat: 9.913668, lng: -84.039017)

        create(:user).profile.update_attributes(
          lat: 9.911512, lng: -84.011358)

        get :index, location_near: '9.913499,-84.034876,1000', format: :json

        expect(response.code).to eql '200'

        expect(json.count).to eql 1
        expect(json.first['id']).to eql other_user.id
      end
    end

    describe 'PUT update' do
      it 'updates profile details', show_in_doc: true do
        put :update, id: user.id, user: {
          profile_attributes: {
            name: 'Guillermo Vargas',
            gender: 'm',
            level: '2.5',
            age: '34',
            about: 'Rails developer',
            location: 'Costa Rica',
            lat: '1.111',
            lng: '-1.321',
            photo_public_id: 'pjxlnrigoijmmeibdi0u',
            hourly_rate: '10.5',
            availability: [
              {
                day: 'mon',
                time: 'night'
              },
              {
                day: 'tue',
                time: 'afternoon'
              }
            ]
          }
        }, format: :json
        expect(response.code).to eql '204'
        user.reload
        expect(user.profile.name).to eql 'Guillermo Vargas'
        expect(user.profile.gender).to eql 'm'
        expect(user.profile.photo_public_id).to eql 'pjxlnrigoijmmeibdi0u'
        expect(user.profile.age).to eql 34
        expect(user.profile.about).to eql 'Rails developer'
        expect(user.profile.level).to eql 2.5
        expect(user.profile.location).to eql 'Costa Rica'
        expect(user.profile.lat).to eql 1.111
        expect(user.profile.lng).to eql -1.321
        expect(user.profile.hourly_rate).to eql 10.5
      end

      it 'sets the user availability', show_in_doc: false do
        patch :update, id: user.id, user: {
          profile_attributes: {
            availability: [
              {
                day: 'mon',
                time: 'night'
              },
              {
                day: 'tue',
                time: 'afternoon'
              }
            ]
          }
        }, format: :json
        user.reload
        expect(user.profile.availabilities.count).to eql 2
        expect(user.profile.availabilities.map(&:day)).to match_array(%w(mon tue))
      end

      it 'updates the existing availabilities and deletes the ones not in the list' do
        user.profile.availabilities.create(day: 'mon', time: 'night')
        user.profile.availabilities.create(day: 'tue', time: 'afternoon')
        user.profile.availabilities.create(day: 'fri', time: 'morning')
        patch :update, id: user.id, user: {
          profile_attributes: {
            availability: [
              { day: 'mon', time: 'morning' },
              { day: 'wed', time: 'afternoon' }
            ]
          }
        }, format: :json
        user.reload
        expect(user.profile.availabilities.count).to eql 2
        expect(user.profile.availabilities.map(&:day)).to match_array(%w(mon wed))
        expect(user.profile.availabilities.find { |a| a.day == 'mon' }.time).to eql 'morning'
        expect(user.profile.availabilities.find { |a| a.day == 'wed' }.time).to eql 'afternoon'
      end
    end

    describe 'GET show' do
      it 'returns the profile info', show_in_doc: true do
        user.profile.skills << create(:skill, name: 'Forehand')
        user.profile.skills << create(:skill, name: 'Backhand')

        user.profile.availabilities.create(day: 'mon', time: 'night')
        user.profile.availabilities.create(day: 'tue', time: 'afternoon')

        get :show, id: user.id, format: :json
        expect(json).to eql({
          'id'=> user.id,
          'email' => user.email,
          'confirmed' => false,
          'matches_count' => 0,
          'stripe_customer_id' => nil,
          'profile' => {
            'name' => user.profile.name,
            'age' => 30,
            'gender' => user.profile.gender,
            'level' => '1.0',
            'location' => user.profile.location,
            'photo_public_id' => nil,
            'about' => user.profile.about,
            'hourly_rate' => 5.99,
            'availability' => [
              { 'day' => 'mon', 'time' => 'night' },
              { 'day' => 'tue', 'time' => 'afternoon' }],
            'skills' => user.profile.skills.map { |s| { 'id' => s.id, 'name' => s.name } }
          }
        })
      end
    end

    describe 'GET locations' do
      it 'returns the user known locations', show_in_doc: true do
        create(:session_request, invited_user: user, status: 'accepted',
                                 days: [create(:session_request_day, accepted: true)],
                                 accepted_locations: [
                                   'Costa Rica Tennis Club', 'Longwood Cricket Club'])

        get :locations, id: user.id, format: :json
        expect(json).to eql(['Costa Rica Tennis Club', 'Longwood Cricket Club'])
      end
    end
  end

end
