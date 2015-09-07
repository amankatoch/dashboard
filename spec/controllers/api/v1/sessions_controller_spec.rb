require 'rails_helper'

RSpec.describe Api::V1::SessionsController, type: :controller do
  let(:user) { create(:user) }

  describe 'POST facebook_login' do
    before { set_api_token_headers }

    it 'creates a user in the app and return the session credentials' do
      allow_any_instance_of(Koala::Facebook::API).to receive(:get_object).with('me').and_return(
        double(name: 'William Blake', email: 'william.blake@gmail.com', uid: 123456)
      )
      expect do
        post :facebook_login, oauth_token: 'ABCDE', format: :json
      end.to change(User, :count).by(1)
      user = User.last
      expect(user.email).to eql 'william.blake@gmail.com'
      expect(user.profile.name).to eql 'William Blake'
      expect(user.authentication_token).to eql json['auth_token']
    end

    it 'does not create a new user if one already exists with the same email' do
      user = create(:user, email: 'william.blake@gmail.com')
      allow_any_instance_of(Koala::Facebook::API).to receive(:get_object).with('me').and_return(
        double(name: 'William Blake', email: 'william.blake@gmail.com', uid: 123456)
      )
      expect do
        post :facebook_login, oauth_token: 'ABCDE', format: :json
      end.to_not change(User, :count)
      expect(json['user_id']).to eql user.id
    end

    it 'does not create a new user if one already exists with the same facebook_id' do
      user = create(:user, facebook_id: 123456)
      allow_any_instance_of(Koala::Facebook::API).to receive(:get_object).with('me').and_return(
        double(name: 'William Blake', email: 'william.blake@gmail.com', uid: 123456)
      )
      expect do
        post :facebook_login, oauth_token: 'ABCDE', format: :json
      end.to_not change(User, :count)
      expect(json['user_id']).to eql user.id
    end
  end
end
