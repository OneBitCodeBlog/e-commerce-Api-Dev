require 'rails_helper'

RSpec.describe "Admin V1 Dashboard Top Five Products as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /dashboard/top_five_products" do
    let(:url) { "/admin/v1/dashboard/top_five_products" }
    let(:params) { { min_date: 5.days.ago.strftime("%Y-%m-%d"), max_date: Date.current.strftime("%Y-%m-%d") } }

    let(:top_five_products) { create_list(:product, 5) }
    let(:less_sold_products) { create_list(:product, 5) }
    let(:order) do 
      order = create(:order, created_at: 4.days.ago)
      order.update_column(:status, :finished)
      order
    end
    let!(:top_five_line_itens) do
      top_five_products.map.with_index do |product, index|
        create(:line_item, payed_price: 200, quantity: (index + 1), order: order, product: product)
      end
    end
    let(:out_of_date_order) do 
      order = create(:order, created_at: 8.days.ago)
      order.update_column(:status, :finished)
      order
    end
    let!(:out_of_date_line_items) do
      less_sold_products.map.with_index do |product, index|
        create(:line_item, payed_price: 2000, quantity: (index + 1), order: out_of_date_order, product: product)
      end
    end
    

    it "returns right top five products" do
      get url, headers: auth_header(user), params: params
      expected_result = top_five_line_itens.reverse.map do |line_item|
        total_sold = line_item.quantity * line_item.payed_price
        { 'product' => line_item.product.name, 'quantity' => line_item.quantity, 'total_sold' => total_sold }
      end
      expect(body_json['top_five_products']).to eq expected_result
    end

    it "returns :ok status" do
      get url, headers: auth_header(user), params: params
      expect(response).to have_http_status(:ok)
    end
  end
end
