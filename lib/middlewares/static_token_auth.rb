class StaticTokenAuth
  TOKEN_TO_VERIFY = Rails.application.credentials.token[:sidekiq]
  
  def initialize(app)
    @app = app
  end

  def call(env)
    token = env.dig('action_dispatch.request.path_parameters', :token)
    if token == TOKEN_TO_VERIFY
      return @app.call(env)
    end
    [401, {}, ['Invalid Token']]
  end
end