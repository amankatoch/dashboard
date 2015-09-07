class Api::V1::PasswordsController < Api::V1::ApiController
  inherit_resources

  actions :create

  skip_before_action :authenticate_user_from_token!

  defaults resource_class: User

  resource_description do
    short 'Password management methods'
    formats ['json']
    error 200, 'No error, operation successful.'
    error 204, 'The request was processed successfully, but no response body is needed.'
    error 401, 'Unauthorized access'
    error 404, 'The requested resource was not found'
    error 406, 'Requested representation not available for the resource'
    error 422, 'Invalid data provided. Check that the params are valid'
    error 500, 'Internal server error.'
    description <<-EOS

    EOS
  end

  api :POST, '/passwords', 'Request password reset instructions email'
  param :user, Hash, required: true do
    param :email, String, required: true, desc: "User's email"
  end
  def create
    resource = User.send_reset_password_instructions(user_params)
    render text: nil
  end

  protected

  def user_params
    params.require(:user).permit(:email)
  end
end
