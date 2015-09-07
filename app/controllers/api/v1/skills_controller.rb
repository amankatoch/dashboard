class Api::V1::SkillsController < Api::V1::ApiController
  inherit_resources

  actions :index

  load_and_authorize_resource param_method: :user_params

  resource_description do
    short 'Skills methods'
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

  api :GET, '/skills', "Get a list of skills"
  example <<-EOS
  GET /api/v1/skills.json

  RESPONSE
  {
      "id": 1,
      "name": "Forehand",
  },
  {
      "id": 2,
      "name": "Backhand",
  },
  {
      "id": 3,
      "name": "Training"
  },
  {
      "id": 4,
      "name": "Serve"
  }
  EOS
  def index
    render json: collection
  end
end
