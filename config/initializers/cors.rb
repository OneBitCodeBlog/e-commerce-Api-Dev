Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete],
                  expose: ['access-token', 'client', 'expiry', 'token-type', 'uid']
  end
end