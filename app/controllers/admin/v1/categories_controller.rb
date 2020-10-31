module Admin::V1
  class CategoriesController < ApiController
    def index
      @categories = Category.all
    end
  end
end
