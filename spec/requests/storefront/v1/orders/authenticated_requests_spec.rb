require 'rails_helper'

RSpec.describe "Storefront V1 Orders as authenticated user", type: :request do
  let(:user) { create(:user) }

  context "GET /orders" do
    let(:url) { "/storefront/v1/orders" }
    let!(:user_orders) { create_list(:order, 10, user: user) }
    let!(:non_user_orders) { create_list(:order, 10) }

    it "returns all user orders" do
      get url, headers: auth_header(user)
      expected_orders = user_orders.as_json(only: %i[id status total_amount payment_type])
      expect(body_json['orders']).to contain_exactly *expected_orders
    end

    it "does not return any non-user orders" do
      get url, headers: auth_header(user)
      unexpected_orders = non_user_orders.as_json(only: %i[id status total_amount payment_type])
      expect(body_json['orders']).to_not include *unexpected_orders
    end

    it "returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "GET /order/:id" do
    context "when user tries to access its own order" do
      let!(:coupon) { create(:coupon) }
      let!(:order) { create(:order, user: user, coupon: coupon) }
      let!(:line_items) { create_list(:line_item, 5, order: order) }
      let(:url) { "/storefront/v1/orders/#{order.id}" }

      it "returns requested Order" do
        get url, headers: auth_header(user)
        expected_line_items = line_items.map do |line_item|
          formatted = line_item.as_json(only: %i[quantity payed_price])
          formatted['product'] = line_item.product.name
          formatted
        end
        expected_order = order.as_json(only: %i[id status total_amount subtotal payment_type])
                              .merge({ 'discount' => coupon.discount_value.to_f, 'line_items' => expected_line_items })
        expect(body_json['order']).to eq expected_order
      end

      it "returns success status" do
        get url, headers: auth_header(user)
        expect(response).to have_http_status(:ok)
      end
    end

    context "when user tries to access another user order" do
      let!(:another_user_order) { create(:order) }
      let(:url) { "/storefront/v1/orders/#{another_user_order.id}" }

      it "returns success status" do
        get url, headers: auth_header(user)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end