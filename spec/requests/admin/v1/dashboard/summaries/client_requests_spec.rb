require 'rails_helper'

RSpec.describe "Admin V1 Dashboard Summaries as :client", type: :request do
  let(:user) { create(:user, profile: :client) }

  context "GET /dashboard/summaries" do
    let(:url) { "/admin/v1/dashboard/summaries" }
    
    before(:each) { get url, headers: auth_header(user) }

    include_examples "forbidden access"
  end
end