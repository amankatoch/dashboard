Apipie.configure do |config|
  config.app_name                = "Practice Gigs API"
  config.api_base_url            = "/api/v1"
  config.doc_base_url            = "/apidoc"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/v1/**/*.rb"

  config.app_info = <<-EOS
  == API token
  Every request to the API require a valid API token to be provided in the +X-Api-Token+ header.

  == User Authentication
  Use the method sessions#create to authenticate a user and get the authorization key

  For those methods that require an authenticated user, you must provide the
  user's email and authentication token in the headers as:
  +X-Auth-Token+ and +X-User-Email+, otherwise, you will receive a response code 401 from the server

  Besides the authentication headers, every request should include the header +Accept+
  with the value "application/json", and if you want to send your params/data as a JSON object,
  you will have to set the header +Content-Type+ to "application/json" too.
  EOS
end
