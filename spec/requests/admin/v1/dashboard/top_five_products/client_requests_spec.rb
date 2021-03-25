require 'rails_helper'

RSpec.describe "Admin V1 Dashboard Top Five Products as :client", type: :request do
  let(:user) { create(:user, profile: :client) }

  context "GET /dashboard/top_five_products" do
    let(:url) { "/admin/v1/dashboard/top_five_products" }
    
    before(:each) { get url, headers: auth_header(user) }

    include_examples "forbidden access"
  end
end
