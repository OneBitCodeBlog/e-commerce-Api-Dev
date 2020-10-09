require 'rails_helper'

RSpec.describe "Admin V1 Categories as :client", type: :request do
  let(:user) { create(:user, profile: :client) }

  context "GET /categories" do
    let(:url) { "/admin/v1/categories" }
    let!(:categories) { create_list(:category, 5) }
    
    before(:each) { get url, headers: auth_header(user) }

    include_examples "forbidden access"
  end

  context "POST /categories" do
    let(:url) { "/admin/v1/categories" }
    let(:categories) { attributes_for(:category) }
    
    before(:each) { post url, headers: auth_header(user) }

    include_examples "forbidden access"
  end

  context "PATCH /categories/:id" do
    let(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }

    before(:each) { patch url, headers: auth_header(user) }

    include_examples "forbidden access"
  end

  context "DELETE /categories/:id" do
    let!(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }

    before(:each) { delete url, headers: auth_header(user) }

    include_examples "forbidden access"
  end
end
