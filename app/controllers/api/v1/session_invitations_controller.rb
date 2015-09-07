module Api
  module V1
    class SessionInvitationsController < Api::V1::ApiController
      inherit_resources

      defaults resource_class: SessionRequest

      authorize_resource class: 'SessionRequest'

      resource_description do
        short 'Sessions invitations methods where a user '\
              'can see and manage the received sessions invitations'
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

      api :GET, '/session_invitations', 'Retrieve a list of sessions invitations received by users'
      def index
        render json: collection, each_serializer: SessionInvitationSerializer
      end

      api :PUT, '/session_invitations/:id', 'Updates an invitation. Allows the user to accept/reject and invitation'
      param :id, :number, 'The session invitation ID'
      param :status, %w(rejected accepted), 'The new status for the invitation.'
      param :comment, String, 'A comment from the user accepting/rejecting the invitation.'
      param :locations, Array, of: String, required: false, desc: 'A list of strings'
      param :days_attributes, Array, required: false do
        param :id, :number, required: true, desc: 'The invitiation day record ID'
        param :accepted, %w(true false), required: true, desc: 'Indicates if this day works for the user.'
        param :time_start, /\A\d{2}:\d{2} (AM|PM)/, required: true, desc: 'The start hour in HH:MM AM/PM format.'
        param :time_end, /\A\d{2}:\d{2} (AM|PM)/, required: true, desc: 'The start hour in HH:MM AM/PM format.'
      end
      def update
        update!
      end

      api :POST, '/session_requests/:id/feedback', 'Register user\'s feedback for a completed session. '\
                 'Use this method to register the invited user\'s feedback about the other player'
      param :feedback, Hash, required: true, action_aware: true do
        param :message, String, required: true, desc: 'The user\'s message about the completed session'
        param :skill_ids, Array, required: false, desc: 'A list of Skills IDS.'
      end
      def feedback
        feedback = resource.sessions_feedbacks
                   .create_with(session_feedback_params)
                   .find_or_create_by(by_user_id: resource.user_id)
        if feedback.persisted?
          render json: feedback, code: 201
        else
          render json: feedback.errors, code: 422
        end
      end

      protected

      def begin_of_association_chain
        current_user
      end

      def session_invitation_params
        params.require(:session_invitation).permit(
          :status, :comment, locations: [], days_attributes: [:id, :accepted, :time_start, :time_end]).tap do |p|
          p[:accepted_locations] = p.delete(:locations) if p.key?(:locations)
          p[:invited_user_comment] = p.delete(:comment) if p.key?(:comment)
          if p.key?(:days_attributes)
            p[:days_attributes].each do |d|
              d[:accepted_time_start] = d.delete(:time_start) if d.key?(:time_start)
              d[:accepted_time_end] = d.delete(:time_end) if d.key?(:time_end)
            end
          end
        end
      end

      def session_feedback_params
        params.require(:feedback).permit(
          :message, skill_ids: []
        ).tap do |p|
          p[:for_user_id] = resource.invited_user_id
        end
      end
    end
  end
end
