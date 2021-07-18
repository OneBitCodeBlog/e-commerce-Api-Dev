require 'rails_helper'

RSpec.describe "Admin V1 Dashboard Sales Ranges as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /dashboard/sales_ranges" do
    let(:url) { "/admin/v1/dashboard/sales_ranges" }

    context "when date range is less than one 1 month" do
      let(:params) { { min_date: 20.days.ago.strftime("%Y-%m-%d"), max_date: Date.current.strftime("%Y-%m-%d") } }

      let(:product) { create(:product) }
        
      let!(:sales_line_items) do
        20.downto(1).map do |num|
          order = create(:order, created_at: num.days.ago)
          order.update_column(:status, :finished)
          create(:line_item, order: order, product: product, payed_price: 200, quantity: num)
        end
      end

      it "returns products in a daily basis" do
        get url, headers: auth_header(user), params: params
        expected_result = sales_line_items.map do |line_item|
          day = line_item.order.created_at.strftime("%Y-%m-%d")
          total_sold = line_item.payed_price * line_item.quantity
          { "date" => day, "total_sold" => total_sold.to_f }
        end
        expect(body_json['sales_ranges']).to eq expected_result
      end

      it "returns :ok status" do
        get url, headers: auth_header(user), params: params
        expect(response).to have_http_status(:ok)
      end
    end

    context "when date range is more than one 1 month" do
      let(:params) { { min_date: 5.months.ago.strftime("%Y-%m-%d"), max_date: Date.current.strftime("%Y-%m-%d") } }

      let(:product) { create(:product) }
        
      let!(:sales_line_items) do
        5.downto(1).map do |num|
          order = create(:order, created_at: num.months.ago)
          order.update_column(:status, :finished)
          create(:line_item, order: order, product: product, payed_price: 200, quantity: num)
        end
      end

      it "returns products in a monthly basis" do
        get url, headers: auth_header(user), params: params
        expected_result = sales_line_items.map do |line_item|
          month = line_item.order.created_at.strftime("%Y-%m")
          total_sold = line_item.payed_price * line_item.quantity
          { "date" => month, "total_sold" => total_sold.to_f }
        end
        expect(body_json['sales_ranges']).to eq expected_result
      end

      it "returns :ok status" do
        get url, headers: auth_header(user), params: params
        expect(response).to have_http_status(:ok)
      end
    end
  end
end