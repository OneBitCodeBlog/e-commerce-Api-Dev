module Storefront
  class ProductsFilterService
    attr_reader :records, :pagination

    def initialize(params = {})
      @records = Product.all
      @params = params || {}
      @pagination = {}
    end
      
    def call
      set_pagination_values
      get_available_products
      searched = filter_records.select("products.*, games.mode, games.developer, games.release_date").distinct
      @records = searched.order(@params[:order].to_h).paginate(@params[:page], @params[:length])
      set_pagination_attributes(searched.size)
    end

    private

    def set_pagination_values
      @params[:page] = @params[:page].to_i
      @params[:length] = @params[:length].to_i
      @params[:page] = Product::DEFAULT_PAGE if @params[:page] <= 0
      @params[:length] = Product::MAX_PER_PAGE if @params[:length] <= 0
    end

    def get_available_products
      @records = @records.joins("JOIN games ON productable_type = 'Game' AND productable_id = games.id")
                         .left_joins(:categories)
                         .includes(productable: [:game], categories: {})
                         .where(status: :available)
    end

    def filter_records
      searched = @records.merge filter_by_search
      searched.merge! filter_by_categories
      searched.merge! filter_by_price
      searched.merge! filter_by_release_date
    end

    def filter_by_search
      return @records.all unless @params.has_key?(:search)
      filtered_records = @records.like(:name, @params[:search])
      filtered_records = filtered_records.or(@records.like(:description, @params[:search]))
      filtered_records.or @records.merge(Game.like(:developer, @params[:search]))
    end

    def filter_by_categories
      return @records.all unless @params.has_key?(:category_ids)
      @records.where(categories: { id: @params[:category_ids] })
    end

    def filter_by_price
      min_price = @params.dig(:price, :min)
      max_price = @params.dig(:price, :max)
      return @records.all if min_price.blank? && max_price.blank?
      @records.where(price: min_price..max_price)
    end
    
    def filter_by_release_date
      min_date = Time.parse(@params.dig(:release_date, :min)).beginning_of_day rescue nil
      max_date = Time.parse(@params.dig(:release_date, :max)).end_of_day rescue nil
      return @records.all if min_date.blank? && max_date.blank?
      Game.where(release_date: min_date..max_date)
    end

    def set_pagination_attributes(total_filtered)
      total_pages = (total_filtered / @params[:length].to_f).ceil
      @pagination.merge!(page: @params[:page], length: @records.size, 
                         total: total_filtered, total_pages: total_pages)
    end
  end
end