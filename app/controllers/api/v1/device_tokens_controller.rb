class Api::V1::DeviceTokensController < Api::V1::ApiController
  inherit_resources

  actions :create

  belongs_to :user

  load_and_authorize_resource :user
  load_and_authorize_resource through: :user

  resource_description do
    short 'User device tokens management methods. Allows a user to have one or more tokens for identifying all it\'s devices'
    formats ['json']
    error 200, "No error, operation successful."
    error 201, "No error, token created."
    error 204, "The request was processed successfully, but no response body is needed."
    error 401, "Unauthorized access"
    error 404, "The requested resource was not found"
    error 406, "Requested representation not available for the resource"
    error 422, "Invalid data provided. Check that the params are valid"
    error 500, "Internal server error."
    description <<-EOS

    EOS
  end

  def_param_group :token do
    param :token, Hash, required: true, action_aware: true do
      param :token, String, required: true, desc: "A unique token identifying the user's device"
      param :device_type, ['ios', 'android'], required: true, desc: "A string identifying the type of device the token if for"
    end
  end

  api :POST, '/users/:user_id/tokens', "Register a device token for a user to recieve push notificaitions"
  param_group :token
  def create
    create!
  end

  protected

  def device_token_params
    params.require(:token).permit(:token, :device_type)
  end

  # For Inherithed resource 1.4.x compatibility, remove once we can upgrade it to 1.5.1
  # see: https://github.com/josevalim/inherited_resources/pull/376
  def permitted_params
    { device_token: device_token_params }
  end
end
