require 'rails_helper'

RSpec.describe "Storefront V1 Coupon Validation without authentication", type: :request do
  
  context "POST /coupons/:coupon_code/validations" do
    let(:coupon) { create(:coupon) }
    let(:url) { "/storefront/v1/coupons/#{coupon.code}/validations" }

    before(:each) { post url }
    
    include_examples "unauthenticated access"
  end
end