require 'rails_helper'

RSpec.describe "Storefront V1 Checkout as authenticated user", type: :request do
  let(:user) { create(:user, [:admin, :client].sample) }
  
  context "POST /checkouts" do
    let(:url) { "/storefront/v1/checkouts" }
    let!(:products) { create_list(:product, 3) }

    context "with valid params" do
      let!(:coupon) { create(:coupon) }
      let(:params) do
        { 
          checkout: { 
            subtotal: 720.95, total_amount: 540.71, payment_type: :credit_card, installments: 2,
            document: '03.000.050/0001-67', card_hash: "123456", address: attributes_for(:address),
            items: [
              { quantity: 2, payed_price: 150.31, product_id: products.first.id },
              { quantity: 3, payed_price: 140.11, product_id: products.second.id }
            ]
          }
        }.to_json
      end

      it 'creates a new Order' do
        expect do
          post url, headers: auth_header, params: params
        end.to change(Order, :count).by(1)
      end

      it 'creates associated Line Items' do
        expect do
          post url, headers: auth_header, params: params
        end.to change(LineItem, :count).by(2)
      end

      it 'returns created Order with associated Line Itens and Coupon' do
        post url, headers: auth_header, params: params
        order = Order.last
        expected_order = order.as_json(only: %i(id payment_type installments))
        expected_order.merge!('subtotal' => order.subtotal.to_f, 'total_amount' => order.total_amount.to_f)
        expect(body_json['order']).to eq expected_order
      end

      it 'returns success status' do
        post url, headers: auth_header, params: params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:invalid_params) do
        { 
          checkout: { 
            subtotal: 0, total_amount: 540.71, payment_type: :credit_card, installments: 2,
            document: '03.000.050/0001-67',
            items: [
              { quantity: 2, payed_price: 150.31, product_id: products.first.id },
              { quantity: 3, payed_price: 140.11, product_id: products.second.id }
            ]
          }
        }.to_json
      end

      it 'does not create a Order' do
        expect do
          post url, headers: auth_header, params: invalid_params
        end.to_not change(Order, :count)
      end

      it 'does not create any Line Items' do
        expect do
          post url, headers: auth_header, params: invalid_params
        end.to_not change(LineItem, :count)
      end

      it 'returns error message' do
        post url, headers: auth_header, params: invalid_params
        expect(body_json['errors']['fields']).to have_key('subtotal')
      end

      it 'returns unprocessable_entity status' do
        post url, headers: auth_header, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
