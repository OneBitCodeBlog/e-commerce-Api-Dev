module Admin::V1::Dashboard
  class TopFiveProductsController < DashboardController
    def index
      @service = Admin::Dashboard::TopFiveProductsService.new(min: get_date(:min_date), max: get_date(:max_date))
      @service.call
    end
  end
end