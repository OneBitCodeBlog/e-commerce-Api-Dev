module RequestAPI
  def body_json(symbolize_keys: false)
    json = JSON.parse(response.body)
    symbolize_keys ? json.deep_symbolize_keys : json
  rescue
    return {} 
  end

  def auth_header(user = nil, merge_with: {})
    user ||= create(:user)
    auth_header = user.create_new_auth_token
    merge_with.merge auth_header
  end
end

RSpec.configure do |config|
  config.include RequestAPI, type: :request
end