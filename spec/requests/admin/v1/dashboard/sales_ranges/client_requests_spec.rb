require 'rails_helper'

RSpec.describe "Admin V1 Dashboard Sales Ranges as :client", type: :request do
  let(:user) { create(:user, profile: :client) }

  context "GET /dashboard/sales_ranges" do
    let(:url) { "/admin/v1/dashboard/sales_ranges" }
    
    before(:each) { get url, headers: auth_header(user) }

    include_examples "forbidden access"
  end
end