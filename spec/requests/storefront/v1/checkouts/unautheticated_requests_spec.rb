require 'rails_helper'

RSpec.describe "Storefront V1 Checkouts without authentication", type: :request do
  
  context "POST /checkouts" do
    let(:url) { "/storefront/v1/checkouts" }

    before(:each) { post url }
    
    include_examples "unauthenticated access"
  end
end
