require 'rails_helper'

RSpec.describe "Admin V1 Orders as :client", type: :request do
  let(:user) { create(:user, profile: :client) }

  context "GET /orders" do
    let(:url) { "/admin/v1/orders" }
    let!(:orders) { create_list(:order, 5) }
    
    before(:each) { get url, headers: auth_header(user) }

    include_examples "forbidden access"
  end

  context "GET /orders/:id" do
    let(:order) { create(:order) }
    let(:url) { "/admin/v1/orders/#{order.id}" }

    before(:each) { get url, headers: auth_header(user) }

    include_examples "forbidden access"
  end
end