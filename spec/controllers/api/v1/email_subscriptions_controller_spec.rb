require 'rails_helper'

RSpec.describe Api::V1::EmailSubscriptionsController, type: :controller do
  let(:user) { create(:user) }

  describe 'with valid credentials' do
    before { set_api_token_headers }

    it 'creates a subscription', show_in_doc: true do
      expect do
        post :create, subscription: { email: 'test@email.com' }, format: :json
      end.to change(Subscription, :count).by(1)
    end
  end
end
