require 'rails_helper'

RSpec.describe Api::V1::DeviceTokensController, type: :controller do
  let(:user) { create(:user) }

  describe 'with valid credentials' do
    before { set_api_authentication_headers user }

    describe 'POST create' do
      let(:token) { '<some-valid-token>' }

      it 'creates a new request for :invited_user', show_in_doc: true do
        expect do
          post :create, user_id: user.id, format: :json, token: {
            token: token, device_type: 'ios'
          }
        end.to change(DeviceToken, :count).by(1)
        device_token = DeviceToken.last
        expect(device_token.user).to eql user
        expect(device_token.token).to eql token
        expect(device_token.device_type).to eql 'ios'
      end

      it 'unassigns the token from any other user' do
        other_user = create(:user)
        other_user.device_tokens.create(token: token, device_type: 'ios')
        expect do
          post :create, user_id: user.id, format: :json, token: {
            token: token, device_type: 'ios'
          }
        end.to_not change(DeviceToken, :count)
        device_token = DeviceToken.last
        expect(device_token.user).to eql user
        expect(device_token.token).to eql token
        expect(device_token.device_type).to eql 'ios'

        expect(other_user.device_tokens.count).to eql 0
      end
    end
  end
end