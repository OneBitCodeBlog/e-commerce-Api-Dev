require 'rails_helper'

RSpec.describe "Admin V1 Orders as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /orders" do
    let(:url) { "/admin/v1/orders" }
    let!(:orders) { create_list(:order, 10) }
    
    context "without any params" do
      it "returns 10 Orders" do
        get url, headers: auth_header(user)
        expect(body_json['orders'].count).to eq 10
      end
      
      it "returns 10 first Orders" do
        get url, headers: auth_header(user)
        expected_orders = orders[0..9].as_json(only: %i[id status total_amount payment_type])
        expect(body_json['orders']).to contain_exactly *expected_orders
      end

      it "returns success status" do
        get url, headers: auth_header(user)
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total: 10, total_pages: 1 } do
        before { get url, headers: auth_header(user) }
      end
    end

    context "with pagination params" do
      let(:page) { 2 }
      let(:length) { 5 }

      let(:pagination_params) { { page: page, length: length } }

      it "returns records sized by :length" do
        get url, headers: auth_header(user), params: pagination_params
        expect(body_json['orders'].count).to eq length
      end
      
      it "returns orders limited by pagination" do
        get url, headers: auth_header(user), params: pagination_params
        expected_orders = orders[5..9].as_json(only: %i[id status total_amount payment_type])
        expect(body_json['orders']).to contain_exactly *expected_orders
      end

      it "returns success status" do
        get url, headers: auth_header(user), params: pagination_params
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 2, length: 5, total: 10, total_pages: 2 } do
        before { get url, headers: auth_header(user), params: pagination_params }
      end
    end

    context "with order params" do
      let(:order_params) { { order: { created_at: 'desc' } } }

      it "returns ordered orders limited by default pagination" do
        get url, headers: auth_header(user), params: order_params
        orders.sort! { |a, b| b[:created_at] <=> a[:created_at]}
        expected_orders = orders[0..9].as_json(only: %i[id status total_amount payment_type])
        expect(body_json['orders']).to contain_exactly *expected_orders
      end
 
      it "returns success status" do
        get url, headers: auth_header(user), params: order_params
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total: 10, total_pages: 1 } do
        before { get url, headers: auth_header(user), params: order_params }
      end
    end
  end

  context "GET /orders/:id" do
    let!(:coupon) { create(:coupon) }
    let!(:order) { create(:order, coupon: coupon) }
    let!(:line_items) { create_list(:line_item, 5, order: order) }
    let(:url) { "/admin/v1/orders/#{order.id}" }

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
end
