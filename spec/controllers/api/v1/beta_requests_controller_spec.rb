require 'rails_helper'

RSpec.describe Api::V1::BetaRequestsController, type: :controller do
  let(:user) { create(:user) }

  describe 'with valid credentials' do
    before { set_api_token_headers }

    describe 'POST create' do

      it 'creates a new beta request', show_in_doc: true do
        expect do
          post :create, format: :json, beta_request: {
            name: 'Fulanito de Tal',
            email: 'fulanito@gmail.com'
          }
        end.to change(BetaRequest, :count).by(1)
        beta_request = BetaRequest.last
        expect(json).to eql(
          'id' => beta_request.id,
          'name' => 'Fulanito de Tal',
          'email' => 'fulanito@gmail.com'
        )
        expect(beta_request.name).to eql 'Fulanito de Tal'
        expect(beta_request.email).to eql 'fulanito@gmail.com'
      end
    end
  end
end
