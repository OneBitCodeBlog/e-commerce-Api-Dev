require "rails_helper"

describe StaticTokenAuth do
  let(:app) { ->(env){ [200, env, "my middleware spec"] } }
  let(:token) { Rails.application.credentials.token[:sidekiq] }

  it "returns 401 when it does not have any token" do
    env_mock = Rack::MockRequest.env_for("my.testing.com")
    middleware = described_class.new(app)
    response = middleware.call(env_mock)
    expect(response.first).to eq 401
  end

  it "returns 401 when token is invalid" do
    env_mock = Rack::MockRequest.env_for("my.testing.com?token=some_random_token")
    middleware = described_class.new(app)
    response = middleware.call(env_mock)
    expect(response.first).to eq 401
  end

  it "returns 200 when token is valid" do
    env_mock = Rack::MockRequest.env_for("my.testing.com?token=#{token}")
    middleware = described_class.new(app)
    response = middleware.call(env_mock)
    expect(response.first).to eq 200
  end
end