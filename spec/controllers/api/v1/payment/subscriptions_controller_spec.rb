require 'rails_helper'

RSpec.describe Api::V1::Payment::SubscriptionsController, type: :controller do

  let(:user) { create(:user) }
  let(:stripe_helper) { StripeMock.create_test_helper }

  before { StripeMock.start }
  after { StripeMock.stop }

  describe 'with valid credentials' do
    before { set_api_authentication_headers user }

    before { user.ensure_stripe_customer! }

    describe 'GET index' do
      it 'returns empty when no subscriptons have been created for user' do
        get :index, format: :json
      end

      it 'returns all the user subscriptons', :show_in_doc do
        plan = stripe_helper.create_plan(id: 'my_plan', amount: 1500)
        subscription = user.stripe_customer.subscriptions.create(plan: 'my_plan', source: stripe_helper.generate_card_token)
        get :index, format: :json
        expect(json.count).to eql 1
        expect(json.first.keys).to eql [
          "id", "current_period_start", "current_period_end", "status", 
          "plan", "cancel_at_period_end", "canceled_at", "ended_at", "start", 
          "object", "trial_start", "trial_end", "customer", "quantity", 
          "tax_percent", "metadata"]
      end
    end

    describe 'POST create' do
      let(:plan) { stripe_helper.create_plan(id: 'test_subscription_plan', amount: 7) }
      before { Settings.create(key: 'stripe_subscription_plan', value: plan.id) }

      it 'returns empty when no cards have been associated to user' do
        get :index, format: :json
      end

      it 'associates the card to the user and returns the details', :show_in_doc do
        post :create, source: stripe_helper.generate_card_token, format: :json
        expect(json['object']).to eql 'subscription'
        expect(json['id']).to_not be_empty
        expect(json['plan']['id']).to eql 'test_subscription_plan'
      end
    end
  end
end
