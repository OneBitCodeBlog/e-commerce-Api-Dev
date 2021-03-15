module Admin
  class FinishDeliveredOrdersService
    def self.call
      delivered_orders = Order.includes(:line_items).where(status: :payment_accepted).select do |order|
        order.line_items.all?(&:delivered?)
      end
      Order.where(id: delivered_orders.map(&:id)).update_all(status: :finished)
    end
  end
end