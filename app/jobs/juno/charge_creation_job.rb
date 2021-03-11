class Juno::ChargeCreationJob < ApplicationJob
  queue_as :default

  def perform(order, order_params)
    order.attributes = order_params.slice(:document, :card_hash)
    order.address = Address.new(order_params[:address])
    Juno::ChargeCreationService.new(order).call
  end
end
