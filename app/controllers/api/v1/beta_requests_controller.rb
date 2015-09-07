class Api::V1::BetaRequestsController < Api::V1::ApiController
  inherit_resources

  skip_before_action :authenticate_user_from_token!

  actions :create

  resource_description do
    short 'Beta Request suscriptions'
    formats ['json']
    error 200, "No error, operation successful."
    error 201, "No error, user created."
    error 204, "The request was processed successfully, but no response body is needed."
    error 401, "Unauthorized access"
    error 404, "The requested resource was not found"
    error 406, "Requested representation not available for the resource"
    error 422, "Invalid data provided. Check that the params are valid"
    error 500, "Internal server error."
    description <<-EOS

    EOS
  end

  def_param_group :beta_request do
    param :beta_request, Hash, required: true, action_aware: true do
      param :name, String, required: true, desc: 'The users name'
      param :email, String, required: true, desc: 'The users email'
    end
  end

  api :POST, '/beta_requests', "Register a new beta request"
  param_group :beta_request
  def create
    create!
  end

  protected

  def beta_request_params
    params.require(:beta_request).permit(:name, :email)
  end
end
