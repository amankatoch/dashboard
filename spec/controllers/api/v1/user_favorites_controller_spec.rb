require 'rails_helper'

describe Api::V1::UserFavoritesController, type: :controller do

  let(:user) { create(:user) }

  describe 'with valid credentials' do
    before { set_api_authentication_headers user }

    describe 'GET index' do
      it 'returns a list of user favorites', show_in_doc: true do
        user.user_favorites << [
          create(:user_favorite, favorite: create(:user)),
          create(:user_favorite, favorite: create(:user))]

        get :index, user_id: user.id, format: :json
        expect(json.count).to eql 2
        expect(json.first.keys).to eql(%w(id ordering favorite))
      end
    end
  end
end