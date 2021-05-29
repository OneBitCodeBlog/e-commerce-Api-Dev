require 'rails_helper'

RSpec.describe "Admin V1 Dashboard Summaries without authentication", type: :request do
  
  context "GET /dashboard/summaries" do
    let(:url) { "/admin/v1/dashboard/summaries" }

    before(:each) { get url }
    
    include_examples "unauthenticated access"
  end
end