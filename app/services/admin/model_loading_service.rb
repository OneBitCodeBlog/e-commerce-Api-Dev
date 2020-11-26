module Admin  
  class ModelLoadingService
    attr_reader :records, :page, :length, :total_pages

    def initialize(searchable_model, params = {})
      @searchable_model = searchable_model
      @params = params || {}
      @records = []
      @page = @params[:page].to_i
      @length = @params[:length].to_i
    end

    def call
      filtered = @searchable_model.search_by_name(@params.dig(:search, :name))
      @records = filtered.order(@params[:order].to_h).paginate(@page, @length)
      @page = @searchable_model.model::DEFAULT_PAGE if @page.zero?
      @length = @searchable_model.model::MAX_PER_PAGE if @length.zero?
      @total_pages = (filtered.count / @length.to_f).ceil
    end
  end
end