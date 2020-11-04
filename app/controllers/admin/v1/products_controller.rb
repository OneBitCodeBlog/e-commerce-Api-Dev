module Admin::V1
  class ProductsController < ApiController
    def index
      @products = load_products
    end

    private

    def load_products
      permitted = params.permit({ search: :name }, { order: {} }, :page, :length)
      Admin::ModelLoadingService.new(Product.all, permitted).call
    end
  end
end