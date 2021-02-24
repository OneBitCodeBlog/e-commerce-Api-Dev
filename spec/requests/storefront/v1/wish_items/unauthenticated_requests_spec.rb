require 'rails_helper'

RSpec.describe "Storefront V1 Wish Items without authentication", type: :request do
  
  context "GET /wish_items" do
    let(:url) { "/storefront/v1/wish_items" }
    let!(:wish_items) { create_list(:wish_item, 5) }

    before(:each) { get url }
    
    include_examples "unauthenticated access"
  end

  context "POST /wish_items" do
    let(:url) { "/storefront/v1/wish_items" }
    
    before(:each) { post url }
    
    include_examples "unauthenticated access"
  end

  context "DELETE /wish_items/:id" do
    let!(:wish_item) { create(:wish_item) }
    let(:url) { "/storefront/v1/wish_items/#{wish_item.id}" }

    before(:each) { delete url }
    
    include_examples "unauthenticated access"
  end
end