module Storefront::V1
  class WishItemsController < ApiController

    def index
      @wish_items = current_user.wish_items.joins(:product)
                                           .includes(:product)
                                           .order("products.name ASC")                                  
    end

    def create
      @wish_item = current_user.wish_items.build(wish_item_params)
      @wish_item.save!
      render :show
    rescue ActiveRecord::RecordInvalid 
      render_error(fields: @wish_item.errors.messages)
    end

    def destroy
      @wish_item = current_user.wish_items.find(params[:id])
      @wish_item.destroy!
    rescue ActiveRecord::RecordNotFound 
      head :not_found
    end

    private

    def wish_item_params
      params.require(:wish_item).permit(:product_id)
    end
  end
end