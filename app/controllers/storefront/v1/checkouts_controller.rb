module Storefront::V1
  class CheckoutsController < ApiController
    def create
      run_service
    rescue Storefront::CheckoutProcessorService::InvalidParamsError
      render_error(fields: @service.errors)
    end

    private

    def run_service
      @service = Storefront::CheckoutProcessorService.new(checkout_params)
      @service.call
      render :show
    end

    def checkout_params
      params.require(:checkout).permit(:subtotal, :total_amount, :payment_type, :installments, :coupon, :card_hash,
                                       :document, items: [:quantity, :payed_price, :product_id],
                                       address: [:street, :number, :city, :state, :post_code])
                               .reverse_merge(user_id: current_user.id, installments: 1)
    end
  end
end
