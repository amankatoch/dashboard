class Api::V1::SessionRequestsController < Api::V1::ApiController
  inherit_resources

  actions :create, :update, :index, :show

  custom_actions resource: [:feedback]

  authorize_resource

  resource_description do
    short 'Sessions requests methods to allow users send and manage invitations for other users.'
    formats ['json']
    error 200, 'No error, operation successful.'
    error 201, 'No error, request created.'
    error 204, 'The request was processed successfully, but no response body is needed.'
    error 401, 'Unauthorized access'
    error 404, 'The requested resource was not found'
    error 406, 'Requested representation not available for the resource'
    error 422, 'Invalid data provided. Check that the params are valid'
    error 500, 'Internal server error.'
    description <<-EOS

    EOS
  end

  def_param_group :session_request do
    param :session_request, Hash, required: true, action_aware: true do
      param :invited_user_id, :number, required: false, desc: 'The ID of the user that is being invited for a session.'
      param :message, String, required: false, desc: 'A string with the message from the current user for the user that is beign invited'
      param :locations, Array, of: String, required: false, desc: 'A list of strings'
      param :days_attributes, Array, required: false, action_aware: true do
        param :date, %r{\A\d{4}/\d\d?/\d\d?\z}, required: true, desc: 'The date in YYYY/MM/DD format'
        param :time_start, /\A\d{2}:\d{2} (AM|PM)/, required: true, desc: 'The start hour in HH:MM AM/PM format.'
        param :time_end, /\A\d{2}:\d{2} (AM|PM)/, required: true, desc: 'The start hour in HH:MM AM/PM format.'
      end
      param :payment_attributes, Hash, required: false do
        param :source, String, requred: false, desc: 'The credit card token to be used for the payment. If not provided, then the default user\'s credit card will be used (if any)'
        param :amount, /[0-9](\.[05])?/, requred: false, desc: 'Amount to charge the user. If not provided, then the invited user\'s hourly rate will be used instead'
      end
    end
  end

  api :GET, '/session_requests', 'Retrieve a list of sessions requests sent to other users'
  def index
    render json: collection
  end

  api :POST, '/session_requests', 'Create a sessions request for a give user'
  param_group :session_request
  def create
    create!
  end

  api :PUT, '/session_requests/:id', 'Updates a session request. Allows the user to confirm an invitation'
  param :id, :number, 'The session invitation ID'
  param :status, %w(confirmed), 'The new status for the invitation.'
  param :location, String, required: false, desc: 'The location where the match is going to be played'
  param :days_attributes, Array, required: false do
    param :id, :number, required: true, desc: 'The invitiation day record ID'
    param :confirmed, %w(true false), required: true, desc: 'Indicates that this is the date/time that both users agreed.'
  end
  def update
    update!
  end

  api :POST, '/session_requests/:id/feedback', 'Register user\'s feedback for a completed session'
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

  def session_request_params
    params.require(:session_request).permit(
      :invited_user_id, :message, :status, :location,
      locations: [], days_attributes: [:id, :date, :time_start, :time_end, :confirmed],
      payment_attributes: [:amount, :source]
    )
  end

  def session_feedback_params
    params.require(:feedback).permit(
      :message, skill_ids: []
    ).tap do |p|
      p[:for_user_id] = resource.invited_user_id
    end
  end
end
