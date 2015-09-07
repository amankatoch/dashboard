module SharedSpecHelpers
  def set_api_authentication_headers(user)
    request.headers['X-Auth-Token'] = user.authentication_token
    request.headers['X-User-Email'] = user.email
    request.headers['X-Api-Token'] = create(:api_token).token
  end

  def set_api_token_headers
    request.headers['X-Api-Token'] = create(:api_token).token
  end

  def json
    @json ||= JSON.parse(response.body)
  end
end