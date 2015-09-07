class Api::V1::UserFavoritesController < Api::V1::ApiController
  inherit_resources

  actions :create, :update

  belongs_to :user

  load_and_authorize_resource :user
  load_and_authorize_resource through: :user

  resource_description do
    short 'User favorites management methods. Provide a set of methods to manage a user\'s favorites'
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

  def_param_group :favorite do
    param :favorite, Hash, required: true, action_aware: true do
      param :favorite_id, :number, required: true, desc: "A user ID to be assigned as a favorite"
      param :ordering, :number, required: false, desc: "The position in the list of favorites for the user."
    end
  end

  api :POST, '/users/:user_id/favorites', "Mark a given user as a favorite for the current user"
  param_group :favorite
  def create
    create!
  end

  api :PATCH, '/users/:user_id/favorites', "Updates a user's favorite attributes"
  param_group :favorite
  def update
    update!
  end

  api :GET, '/users/:user_id/favorites', "Returns a list of user's favorites"
  def index
    render json: collection
  end

  protected

  def user_favorite_params
    params.require(:favorite).permit(:favorite_id, :ordering)
  end

  # For Inherithed resource 1.4.x compatibility, remove once we can upgrade it to 1.5.1
  # see: https://github.com/josevalim/inherited_resources/pull/376
  def permitted_params
    { user_favorite: user_favorite_params }
  end
end
