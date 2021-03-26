require 'rails_helper'

RSpec.describe "Admin V1 Dashboard Sales Ranges without authentication", type: :request do
  
  context "GET /dashboard/sales_ranges" do
    let(:url) { "/admin/v1/dashboard/sales_ranges" }

    before(:each) { get url }
    
    include_examples "unauthenticated access"
  end
end
