module Storefront::V1
  class CouponValidationsController < ApiController
    def create
      @coupon = Coupon.find_by(code: params[:coupon_code])
      @coupon.validate_use!
      render :show
    rescue
      render_error(message: I18n.t('storefront/v1/coupon_validations.create.failure'))
    end
  end
end