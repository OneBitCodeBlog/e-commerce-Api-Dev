require 'rails_helper'

RSpec.describe "Storefront V1 Games without authentication", type: :request do
  
  context "GET /games" do
    let(:url) { "/storefront/v1/games" }
    let!(:games) { create_list(:product, 5) }

    before(:each) { get url }
    
    include_examples "unauthenticated access"
  end
end