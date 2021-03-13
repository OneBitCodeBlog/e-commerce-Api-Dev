class StaticTokenAuth
  TOKEN_TO_VERIFY = Rails.application.credentials.token[:sidekiq]
  
  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    request = Rack::Request.new(env)
    return [status, headers, response] if request.params['token'] == TOKEN_TO_VERIFY
    [401, {}, ['Invalid Token']]
  end
end