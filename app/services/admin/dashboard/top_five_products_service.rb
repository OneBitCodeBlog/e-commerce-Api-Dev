module Admin::Dashboard
  class TopFiveProductsService
    NUMBER_OF_RECORDS = 5

    attr_reader :records

    def initialize(min: nil, max: nil)
      @min_date = min.present? ? min.beginning_of_day : nil
      @max_date = max.present? ? max.end_of_day : nil
      @records = []
    end

    def call
      @records = search_top_five.map do |product|
        build_product_hash(product)
      end
      @records
    end

    private

    def search_top_five
      range_date_orders = Order.where(status: :finished, created_at: @min_date..@max_date)
      Product.joins(line_items: :order).merge(range_date_orders).group(:id)
             .order('total_sold DESC, total_qty DESC')
             .limit(NUMBER_OF_RECORDS)
             .select(:id, :name, line_item_arel[:sold].as('total_sold'), line_item_arel[:quantity].as('total_qty'))
    end

    def build_product_hash(product)
      { 
        product: product.name, 
        image: Rails.application.routes.url_helpers.rails_blob_url(product.image), 
        total_sold: product.total_sold, 
        quantity: product.total_qty 
     }
    end

    def line_item_arel
      return @line_item_arel if @line_item_arel
      arel = LineItem.arel_table
      total_sold = (arel[:payed_price] * arel[:quantity]).sum
      quantity_sum = arel[:quantity].sum
      @line_item_arel = { sold: total_sold, quantity: quantity_sum }
    end
  end
end
