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
        { product: product.first, total_sold: product.second, quantity: product.third }
      end
      @records
    end

    private

    def search_top_five
      range_date_orders = Order.where(status: :finished, created_at: @min_date..@max_date)
      Product.joins(line_items: :order).merge(range_date_orders).group(:id)
             .order(line_item_arel[:total_sold].desc, line_item_arel[:quantity_sum].desc)
             .limit(NUMBER_OF_RECORDS)
             .pluck(:name, line_item_arel[:total_sold], line_item_arel[:quantity_sum])
    end

    def line_item_arel
      return @line_item_arel if @line_item_arel
      arel = LineItem.arel_table
      total_sold = (arel[:payed_price] * arel[:quantity]).sum
      quantity_sum = arel[:quantity].sum
      @line_item_arel = { total_sold: total_sold, quantity_sum: quantity_sum }
    end
  end
end