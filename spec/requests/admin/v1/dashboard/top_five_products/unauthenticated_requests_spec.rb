require 'rails_helper'

RSpec.describe "Admin V1 Dashboard Top Five Products without authentication", type: :request do
  
  context "GET /dashboard/top_five_products" do
    let(:url) { "/admin/v1/dashboard/top_five_products" }

    before(:each) { get url }
    
    include_examples "unauthenticated access"
  end
end