module Storefront::V1
  class OrdersController < ApiController
    def index
      @orders = current_user.orders
    end

    def show
      @order = current_user.orders.includes(:line_items).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_error(message: "Forbidden access", status: :forbidden)
    end
  end
end