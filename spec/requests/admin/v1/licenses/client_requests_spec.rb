require 'rails_helper'

RSpec.describe "Admin V1 Licenses as :client", type: :request do
  let(:user) { create(:user, profile: :client) }

  context "GET /licenses" do
    let(:url) { "/admin/v1/licenses" }
    let!(:licenses) { create_list(:license, 5) }
    
    before(:each) { get url, headers: auth_header(user) }

    include_examples "forbidden access"
  end

  context "POST /licenses" do
    let(:url) { "/admin/v1/licenses" }
    
    before(:each) { post url, headers: auth_header(user) }

    include_examples "forbidden access"
  end

  context "GET /licenses/:id" do
    let(:license) { create(:license) }
    let(:url) { "/admin/v1/licenses/#{license.id}" }

    before(:each) { get url, headers: auth_header(user) }

    include_examples "forbidden access"
  end

  context "PATCH /licenses/:id" do
    let(:license) { create(:license) }
    let(:url) { "/admin/v1/licenses/#{license.id}" }

    before(:each) { patch url, headers: auth_header(user) }

    include_examples "forbidden access"
  end

  context "DELETE /licenses/:id" do
    let!(:license) { create(:license) }
    let(:url) { "/admin/v1/licenses/#{license.id}" }

    before(:each) { delete url, headers: auth_header(user) }

    include_examples "forbidden access"
  end
end
