class Api::V1::SessionsController < Api::V1::ApiController
  skip_before_action :verify_authenticity_token
  skip_before_filter :authenticate_user_from_token!, only: [:create, :facebook_login]

  resource_description do
    short 'User session manager'
    formats ['json']
    error 404, "Missing"
    error 400, "Bad Request"
    error 500, "Server crashed for some reason"
    description <<-EOS
      == Token Authentication

    EOS
  end

  api :POST, '/login', 'Authenticate a user and return the authentication token'
  param :email, String, required: true, desc: "User's email"
  param :password, String, required: true, desc: "User's password"
  formats ['json']
  description <<-EOS
  Validates the user credentials and returns the authentication token if valid.
  EOS
  example <<-EOS
  POST /api/v1/login.json
  POST DATA:
  {
    email: 'fulano@detal.com'
    password: 'MySuperSecretPassword'
  }
  RESPONSE:
  {
    auth_token: 'XXXYYYYZZZ',
    user_id: 1,
    user_email: 'fulano@detal.com'
  }
  EOS
  def create
    resource = User.find_for_database_authentication(email: params[:email])

    if resource && resource.valid_password?(params[:password])
      resource.ensure_authentication_token
      resource.save :validate => false
      sign_in :user, resource, store: false
      render :status => 200,
             :json => {
                :auth_token => resource.authentication_token,
                user_id: resource.id,
                user_email: resource.email }

    else
      render :status => 400,
       :json => { :message => "Login Failed" }
    end
  end

  api :POST, '/facebook_login', 'Authenticate a user using facebook credentials and return the authentication token'
  param :oauth_token, String, required: true, desc: "User's access token returned by Facebook"
  formats ['json']
  description <<-EOS
  Validates the user credentials and returns the authentication token if valid.
  EOS
  def facebook_login
    resource = User.find_or_create_from_facebook_token(params[:oauth_token])

    if resource
      resource.ensure_authentication_token
      resource.save :validate => false
      sign_in :user, resource, store: false
      render :status => 200,
             :json => {
                :auth_token => resource.authentication_token,
                user_id: resource.id,
                user_email: resource.email }

    else
      render :status => 400,
       :json => { :message => "Login Failed" }
    end
  end

  api :DELETE, '/logout', 'Destroy authentication token for a user'
  def destroy
    resource = current_user
    if resource.nil?
      render :status=>404, :json=>{sucess: false, info: 'Invalid token.'}
    else
      resource.reset_authentication_token!

      render :status=>200, :json=>{success: true, info: 'Logged out' + resource.errors.inspect, token: params[:id]}
    end
  end
end