class Api::V1::UsersController < Api::V1::ApiController
  inherit_resources

  actions :create, :update, :show

  skip_before_action :authenticate_user_from_token!, only: [:create]

  load_and_authorize_resource param_method: :user_params

  resource_description do
    short 'User management methods: create, edit and get user details'
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

  def_param_group :user do
    param :user, Hash, required: true, action_aware: true do
      param :email, String, required: true, desc: "User's email"
      param :password, String, required: true, desc: "User's password. Should have between 6 and 128 characters."
      param :password_confirmation, String, required: true, desc: "Password's confirmation"
      param :profile_attributes, Hash, required: true, action_aware: true do
        param :name, String, required: true, desc: "User's title"
        param :gender, %w(f m), required: false, desc: "User's gender."
        param :age, :number, required: true, desc: "User's age. Should be a number between 1 and 100"
        param :about, String, required: false, desc: "User's about data."
        param :level, /[0-9](\.[05])?/, required: false, desc: "User's level. Should be a Float between 1 and 5 including fractions. Examples: 1, 5, 2.5, 3.0"
        param :location, String, required: true, desc: "User's location."
        param :photo_public_id, String, required: false, desc: "User's photo public id returned by Cloudinary's API."
        param :skill_ids, Array, required: false, desc: 'A list of Skills IDS.'
        param :lat, /([+-]?\d+\.?\d+)/, required: false, desc: 'The latitude of user\'s location'
        param :lng, /([+-]?\d+\.?\d+)\s*/, required: false, desc: 'The longitude of user\'s location'
        param :hourly_rate, /[0-9]+(\.[05])?/, required: false, desc: 'The user\'s hourly rate'
        param :availability, Array, required: false do
          param :day, ProfileAvailability::DAYS_OPTIONS, required: true, desc: 'Availability day'
          param :time, ProfileAvailability::TIME_OPTIONS, required: true, desc: 'Availability time'
        end
      end
    end
  end

  api :GET, '/users', 'Search for users based on different search params'

  param :profile_level_eq, :number, 'Search for users whose +level+ is exactly equal to the given value'
  param :profile_level_lteq, :number, 'Search for users whose +level+ is less than or equal to the given value'
  param :profile_level_lt, :number, 'Search for users whose +level+ is less than the given value'
  param :profile_level_gteq, :number, 'Search for users whose +level+ is greater than or equal to the given value'
  param :profile_level_gt, :number, 'Search for users whose +level+ is greater than the given value'
  param :profile_age_lteq, :number, 'Search for users whose +age+ is less than or equal to the given value'
  param :profile_age_lt, :number, 'Search for users whose +age+ is less than the given value'
  param :profile_age_gteq, :number, 'Search for users whose +age+ is greater than or equal to the given value'
  param :profile_age_gt, :number, 'Search for users whose +age+ is greater than the given value'
  param :profile_skills_id_in, Array, 'Search for users that have any of the given skills ids'
  param :profile_gender_eq, %w(m f), 'Search for users with a specific gender'
  param :location_near, /\A([+-]?\d+\.?\d+)\s*,\s*([+-]?\d+\.?\d+)\s*,\s*\d+\s*\z/,
        'Search for users near a specific point. Specify the location in the form: '\
        'latitude,longitude,radius. The radius is an integer indicating meters'
  param :page, :number, 'Allow to specify the page number for paginated results. Default is 1'
  def index
    render json: search_results
  end

  api :POST, '/users', 'Register a new user'
  param_group :user
  see 'skills#index'
  def create
    create!
  end

  api :GET, '/users/:id', "Get a user's details"
  param :id, :number, required: true
  def show
    render json: resource
  end

  api :PUT, '/users/:id', 'Update user\'s data'
  param :id, :number
  param_group :user
  see 'skills#index'
  def update
    update!
  end

  api :GET, '/users/:id/locations', 'Get a list of known locations for the user'
  param :id, :number, required: true
  def locations
    render json: current_user.known_locations
  end

  api :GET, '/users/:id/subscription', 'Get info about the user\'s subscription'
  def subscription
    subscription = current_user.active_subscription
    render json: subscription, serializer: UserCurrentSubscription
  end

  protected

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      profile_attributes: [:name, :age, :gender, :level, :location, :about, :photo_public_id,
                           :lat, :lng, :hourly_rate,
                           { skill_ids: [] },
                           { availability: [:day, :time] }]
    ).tap do |p|
      if params[:id] && resource.present? && resource.profile.present?
        p[:profile_attributes][:id] = resource.profile.id
      end
    end
  end

  def search_results
    resource_class.search(search_params).result.includes(:profile).page(params[:page] || 1)
  end

  def search_params
    params.permit(
      :profile_level_eq, :profile_level_lteq, :profile_level_lt,
      :profile_level_gteq, :profile_level_gt, :profile_gender_eq,
      :profile_age_eq, :profile_age_lteq, :profile_age_lt,
      :profile_age_gteq, :profile_age_gt, :location_near,
      profile_skills_id_in: []
    ).merge(id_not_eq: current_user.id)
  end

  # For Inherithed resource 1.4.x compatibility, remove once we can upgrade it to 1.5.1
  # see: https://github.com/josevalim/inherited_resources/pull/376
  def permitted_params
    { user: user_params }
  end

  def user_locations
    SessionRequest.select('')
  end
end
