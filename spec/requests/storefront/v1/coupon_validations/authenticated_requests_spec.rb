require 'rails_helper'

RSpec.describe "Storefront V1 Coupon Validation as authenticated user", type: :request do
  let(:user) { create(:user, [:admin, :client].sample) }

  context "POST /coupons/:coupon_code/validations" do
    context "with valid coupon" do
      let(:coupon) { create(:coupon) }
      let(:url) { "/storefront/v1/coupons/#{coupon.code}/validations" }

      it 'returns success status' do
        post url, headers: auth_header(user)
        expect(response).to have_http_status(:ok)
      end

      it 'returns valid Coupon' do
        post url, headers: auth_header(user)
        expected_coupon = coupon.as_json(only: %i(id code discount_value))
        expect(body_json['coupon']).to eq expected_coupon
      end
    end

    context "with invalid coupon" do
      let(:coupon) { create(:coupon, status: :inactive) }
      let(:url) { "/storefront/v1/coupons/#{coupon.code}/validations" }

      it 'returns unprocessable_entity status' do
        post url, headers: auth_header(user)
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns valid Coupon' do
        post url, headers: auth_header(user)
        failure_message = I18n.t('storefront/v1/coupon_validations.create.failure')
        expect(body_json['errors']['message']).to eq failure_message
      end
    end
  end
end