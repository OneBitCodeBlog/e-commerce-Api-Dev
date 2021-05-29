module Admin::V1::Dashboard
  class SummariesController < DashboardController
    def index
      @service = Admin::Dashboard::SummaryService.new(min: get_date(:min_date), max: get_date(:max_date))
      @service.call
    end
  end
end