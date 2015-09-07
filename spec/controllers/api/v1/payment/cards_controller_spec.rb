require 'rails_helper'

RSpec.describe Api::V1::Payment::CardsController, type: :controller do

  let(:user) { create(:user) }
  let(:stripe_helper) { StripeMock.create_test_helper }

  before { StripeMock.start }
  after { StripeMock.stop }

  describe 'with valid credentials' do
    before { set_api_authentication_headers user }

    before { user.ensure_stripe_customer! }

    describe 'GET index' do
      it 'returns empty when no cards have been associated to user' do
        get :index, format: :json
      end

      it 'returns all the cards associated', :show_in_doc do
        user.stripe_customer.sources.create(card: stripe_helper.generate_card_token)
        get :index, format: :json
        expect(json.count).to eql 1
      end
    end

    describe 'POST create' do
      it 'returns empty when no cards have been associated to user' do
        get :index, format: :json
      end

      it 'returns all the cards associated', :show_in_doc do
        post :create, card: { card: stripe_helper.generate_card_token }, format: :json
        expect(json['object']).to eql 'card'
        expect(json['id']).to_not be_empty
      end
    end
  end
end
