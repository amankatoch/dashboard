class Api::V1::ApiController < ApplicationController

  respond_to :json

  #before_action :validate_api_token!
  #before_action :authenticate_user_from_token!

  after_action :update_token_last_used_date

  protect_from_forgery with: :null_session,
      if: Proc.new { |c| c.request.format == 'application/json' }

  skip_before_filter :verify_authenticity_token,
      if: Proc.new { |c| c.request.format == 'application/json' }

  rescue_from 'Api::V1::InvalidAuthToken', with: :invalid_auth_token
  rescue_from 'Api::V1::InvalidApiToken', with: :invalid_api_token
  rescue_from 'ActiveRecord::RecordNotFound', with: :record_not_found
  rescue_from CanCan::AccessDenied, with: :access_denied
  rescue_from 'Apipie::ParamInvalid', with: :invalid_argument
  rescue_from 'Apipie::ParamMissing', with: :invalid_argument

  before_action :ensure_valid_request
  before_action :cors_preflight_check
  after_action :set_access_control_headers

  protected

  def record_not_found
    render :status => 404,
           :json => { :message => "Record not found" }
  end

  def invalid_auth_token
    render :status => 401,
           :json => { :message => "Invalid X-Auth-Token" }
  end

  def invalid_api_token
    render :status => 401,
           :json => { :message => "Invalid X-Api-Token" }
  end

  def access_denied
    render :status => 401,
           :json => { :message => "You are not allowed to perform this action" }
  end

  def ensure_valid_request
    return if ['json', 'xml'].include?(params[:format]) || request.headers["Accept"] =~ /json|xml/
    render :nothing => true, :status => 406
  end

  def cors_preflight_check
    return unless request.method == 'OPTIONS'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS, HEAD'
    headers['Access-Control-Allow-Headers'] = '*,x-requested-with,Content-Type,If-Modified-Since,If-None-Match'
    headers['Access-Control-Max-Age'] = '86400'
    render :text => '', :content_type => 'text/plain'
  end

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Expose-Headers'] = 'ETag'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS, HEAD'
    headers['Access-Control-Allow-Headers'] = '*,x-requested-with,Content-Type,If-Modified-Since,If-None-Match'
    headers['Access-Control-Max-Age'] = '86400'
  end

  def validate_api_token!

    token = request.headers['X-Api-Token'].try(:strip)
     binding.pry
    fail Api::V1::InvalidApiToken.new(token) unless token.present?

    @api_token = ApiToken.find_by(token: token)

    fail Api::V1::InvalidApiToken.new(token) unless @api_token.present?
  end

  # Validate token authentication via headers
  def authenticate_user_from_token!
    
    token = request.headers['X-Auth-Token']
    email = request.headers['X-User-Email']

    user = email && User.find_by(email: email)

    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, token)
      request.env['devise.skip_trackable'] = true
      sign_in :user, user, store: false
    else
      raise Api::V1::InvalidAuthToken.new(token)
    end
  end

  def update_token_last_used_date
    @api_token.update_column(:last_used_at, Time.now) if @api_token.present?
  end

  def invalid_argument(exception)
    respond_to do |format|
      format.json do
        render status: 400,
               json: { success: false,
                       info: exception.message }
      end
    end
  end
end

class Api::V1::InvalidAuthToken < StandardError; end
class Api::V1::InvalidApiToken < StandardError; end
