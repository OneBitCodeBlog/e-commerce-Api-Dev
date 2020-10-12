require 'rails_helper'

RSpec.describe "Auth V1 Sign in", type: :request do
  context "as :admin" do
    let!(:user) { create(:user, email: "admin@test.com", password: "123456") }

    include_examples 'sign in', 'admin@test.com', '123456'
  end

  context "as :client" do
    let!(:user) { create(:user, profile: :client, email: "client@test.com", password: "123456") }

    include_examples 'sign in', 'client@test.com', '123456'
  end
end
