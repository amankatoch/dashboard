class Api::V1::MatchesController < Api::V1::ApiController
  inherit_resources

  actions :create, :update, :index, :show

  custom_actions resource: [:feedback]

  defaults resource_class: SessionRequest

  authorize_resource class: 'SessionRequest'

  resource_description do
    short 'Sessions requests methods to allow users send and manage invitations for other users.'
    formats ['json']
    error 401, 'Unauthorized access'
    error 404, 'The requested resource was not found'
    error 406, 'Requested representation not available for the resource'
    error 422, 'Invalid data provided. Check that the params are valid'
    error 500, 'Internal server error.'
    description <<-EOS

    EOS
  end

  api :GET, '/matches', 'Retrieve a list of matches for the current user'
  param :status_in, Array, 'Filter the list of matches by status: ' +
                            SessionRequest.statuses.map { |k, v| "#{v}: #{k}" }.join(', ')
  param :page, :number, 'Allow to specify the page number for paginated results. Default is 1'

  def index
    render json: collection, each_serializer: MatchSerializer, scope: { current_user: current_user }
  end

  protected

  def collection
    get_collection_ivar || set_collection_ivar(
      end_of_association_chain.order('created_at DESC').for_user(current_user)
      .search(search_params).result #.page(params[:page] || 1)
    )
  end

  def search_params
    params.permit(:page, status_in: [])
  end

  def session_request_params
    params.require(:session_request).permit(
      :invited_user_id, :message, :status, :location,
      locations: [], days_attributes: [:id, :date, :time_start, :time_end, :confirmed]
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
