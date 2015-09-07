module Api
  module V1
    class NotificationsController < Api::V1::ApiController
      inherit_resources

      actions :update, :index

      authorize_resource

      resource_description do
        short 'User notifications methods: get and update notifications'
        formats ['json']
        error 200, 'No error, operation successful.'
        error 201, 'No error, user created.'
        error 204, 'The request was processed successfully, but no response body is needed.'
        error 401, 'Unauthorized access'
        error 404, 'The requested resource was not found'
        error 406, 'Requested representation not available for the resource'
        error 422, 'Invalid data provided. Check that the params are valid'
        error 500, 'Internal server error.'
        description <<-EOS

        EOS
      end

      api :GET, '/notifications', 'Get a list of user notifications'
      param :status_in, Array, in: Notification.statuses.values,
            desc: 'Filter notifications by it\'s status where: ' +
            Notification.statuses.map{|k,v| "#{k}=#{v}"}.join(', ')
      param :page, :number, desc: 'Allow to specify the page number for paginated results. Default is 1'
      def index
        render json: collection
      end

      api :PUT, '/notifications/update_status', 'Update the status of one or more notifications'
      param :ids, Array, desc: 'A list of notification ids to be updated', required: true
      param :status, Notification.statuses.values,
            required: true,
            desc: 'The new status for the notifications, where: ' +
                  Notification.statuses.map{|k,v| "#{k}=#{v}"}.join(', ')
      def update_status
        begin_of_association_chain.notifications.where(id: params[:ids]).update_all(status: params[:status])
        head :no_content
      end

      protected

      def collection
        end_of_association_chain.search(search_params).result.preload(user: :profile).page(params[:page] || 1)
      end

      def search_params
        params.permit(status_in: [])
      end

      def begin_of_association_chain
        current_user
      end
    end
  end
end
