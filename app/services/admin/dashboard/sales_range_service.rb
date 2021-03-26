module Admin::Dashboard
  class SalesRangeService
    NUMBER_OF_RECORDS = 5

    attr_reader :records

    def initialize(min: nil, max: nil)
      @min_date = min.present? ? min.beginning_of_day : nil
      @max_date = max.present? ? max.end_of_day : nil
      @records = {}
    end

    def call
      if @max_date.present? && @min_date.present? && @max_date - @min_date < 1.month
        @records = group_sales_by_day.to_h
      else
        @records = group_sales_by_month.to_h
      end
    end

    private

    def group_sales_by_day
      order_filter
        .group("year, month, day")
        .pluck(order_arel[:year], order_arel[:month], order_arel[:day], line_item_arel[:total_sold])
        .map { |record| [format_date(*record[0..2]), record[3]] }
    end

    def group_sales_by_month
      order_filter
        .group("year, month")
        .pluck(order_arel[:year], order_arel[:month], line_item_arel[:total_sold])
        .map { |record| [format_date(*record[0..1]), record[2]] }
    end

    def order_filter
      Order.joins(:line_items).where(status: :finished, created_at: @min_date..@max_date)
    end

    def format_date(year, month, day = nil)
      year = "%04d" % year
      month = ("-" + "%02d" % month)
      day = ("-" + "%02d" % day) if day.present?
      year + month + day.to_s
    end

    def line_item_arel
      @line_item_arel if @line_item_arel.present?
      arel = LineItem.arel_table
      total_sold = (arel[:payed_price] * arel[:quantity]).sum.as('total_sold')
      @line_item_arel = { total_sold: total_sold }
    end

    def order_arel
      @order_arel if @order_arel.present?
      field = Order.arel_table[:created_at]
      @order_arel = { month: field.extract('month').as('month'), year: field.extract('year').as('year'), 
                      day: field.extract('day').as('day') }
    end
  end
end