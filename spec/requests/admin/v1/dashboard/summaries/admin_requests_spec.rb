require 'rails_helper'

RSpec.describe "Admin V1 Dashboard Summaries as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /dashboard/summaries" do
    let(:url) { "/admin/v1/dashboard/summaries" }
    let(:params) { { min_date: 3.days.ago.strftime("%Y-%m-%d"), max_date: Date.current.strftime("%Y-%m-%d") } }
    let!(:users) { create_list(:user, 5, created_at: 2.days.ago) }
    let!(:users_out_of_range) { create_list(:user, 5, created_at: 4.days.ago) }
    let!(:products) { create_list(:product, 5, created_at: 2.days.ago) }
    let!(:products_out_of_range) { create_list(:product, 5, created_at: 4.days.ago) }
    let!(:orders) do
      create_list(:order, 5, user: user, created_at: 2.days.ago, total_amount: 54.15).map do |order|
        order.update_column(:status, :finished)
        order
      end
    end
    let!(:orders_out_of_range) do 
      create_list(:order, 5, user: user, created_at: 4.days.ago, total_amount: 54.15).map do |order|
        order.update_column(:status, :finished)
        order
      end
    end

    it "returns right summary of data" do
      get url, headers: auth_header(user), params: params
      expected_profit = orders.sum(&:total_amount)
      expected_result = { 
        users: users.size + 1, products: products.size, orders: orders.size, profit: expected_profit 
      }.as_json
      expect(body_json['summary']).to eq expected_result
    end

    it "returns :ok status" do
      get url, headers: auth_header(user), params: params
      expect(response).to have_http_status(:ok)
    end
  end
end