require 'rails_helper'

RSpec.describe Api::V1::NotificationsController, :type => :controller do
  let(:user) { create(:user) }

  describe 'with valid credentials' do
    before { set_api_authentication_headers user }

    describe 'GET index' do
      it 'filters the list by status returns ', show_in_doc: true do
        notif1 = create(:notification, user: user, title: 'test notifcation 1',
                                       related_user: create(:user))
        notif2 = create(:notification, user: user, title: 'test notifcation 2',
                                       related_user: create(:user), status: 1)

        create(:notification, user: user, title: 'test notifcation 2',
                              related_user: create(:user), status: 2)

        get :index, status_in: [0, 1], format: :json
        expect(json).to eql([
          { 'id' => notif1.id, 'title' => 'test notifcation 1', 'status' => 'unread',
            'created_at' => notif1.created_at.as_json,
            'user' => { 'id' => notif1.related_user.id, 'name' => notif1.related_user.name } },
          { 'id' => notif2.id, 'title' => 'test notifcation 2', 'status' => 'read',
            'created_at' => notif2.created_at.as_json,
            'user' => { 'id' => notif2.related_user.id, 'name' => notif2.related_user.name } }])
      end

      it 'returns the a list of notifications', show_in_doc: false do
        notif1 = create(:notification, user: user, title: 'test notifcation 1',
                                       related_user: create(:user))
        notif2 = create(:notification, user: user, title: 'test notifcation 2',
                                       related_user: create(:user), status: 1)

        get :index, format: :json
        expect(json).to eql([
          { 'id' => notif1.id, 'title' => 'test notifcation 1', 'status' => 'unread',
            'created_at' => notif1.created_at.as_json,
            'user' => { 'id' => notif1.related_user.id, 'name' => notif1.related_user.name } },
          { 'id' => notif2.id, 'title' => 'test notifcation 2', 'status' => 'read',
            'created_at' => notif2.created_at.as_json,
            'user' => { 'id' => notif2.related_user.id, 'name' => notif2.related_user.name } }])
      end
    end


    describe 'PUT update_status' do
      it 'filters the list by status returns ', show_in_doc: true do
        notif1 = create(:notification, user: user, title: 'test notifcation 1',
                                       related_user: create(:user))
        notif2 = create(:notification, user: user, title: 'test notifcation 2',
                                       related_user: create(:user), status: 1)

        create(:notification, user: user, title: 'test notifcation 2',
                              related_user: create(:user), status: 2)

        expect(notif1.status).to eql 'unread'
        put :update_status, status: 1, ids: [notif1.id], format: :json
        expect(response.code).to eql '204'
        expect(notif1.reload.status).to eql 'read'
      end
    end
  end
end
