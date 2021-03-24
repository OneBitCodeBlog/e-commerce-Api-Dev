module Admin::Dashboard
  class SummaryService
    attr_reader :records

    def initialize(min: nil, max: nil)
      @min_date = min.present? ? min.beginning_of_day : nil
      @max_date = max.present? ? max.end_of_day : nil
      @records = {}
    end

    def call
      @records[:users] = User.where(created_at: @min_date..@max_date).count
      @records[:products] = Product.where(created_at: @min_date..@max_date).count
      calculate_orders
    end

    private

    def calculate_orders
      arel = Order.arel_table
      calc = Order.where(status: :finished, created_at: @min_date..@max_date)
                  .pluck(arel[:id].count, arel[:total_amount].sum).flatten
      @records[:orders] = calc.first
      @records[:profit] = calc.second
    end
  end
end