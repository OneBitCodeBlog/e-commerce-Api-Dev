require_relative "../../../lib/juno_api/charge"
require_relative "../../../lib/juno_api/credit_card_payment"

module Juno
  class ChargeCreationService
    PAYMENT_ERROR_CODES = %W[289999 509999]

    def initialize(order)
      @order = order
    end

    def call
      create_charges
      create_credit_card_payment if @order.credit_card?
      CheckoutMailer.with(order: @order).success.deliver_later
    rescue JunoApi::RequestError => e
      set_order_error(e.error)
    end

    private

    def create_charges
      charges = JunoApi::Charge.new.create!(@order)
      Juno::Charge.transaction do
        charges.each.with_index { |charge, index| create_charge(charge, index + 1) }
      end
      @order.update!(status: :waiting_payment)
    end

    def create_credit_card_payment
      credit_card_payments = JunoApi::CreditCardPayment.new.create!(@order)
      Juno::CreditCardPayment.transaction do
        credit_card_payments.each { |payment| create_charge_payment(payment) }
      end
      @order.update!(status: :payment_accepted)
    end

    def set_order_error(error)
      if error.present? && PAYMENT_ERROR_CODES.include?(error.first['error_code'])
        set_payment_denied_error(error.first['message'])
      else
        set_generic_error
      end
    end

    def create_charge(charge, position)
      charge.merge!(number: position)
      charge[:billet_url] = charge.delete(:installment_link)
      charge[:key] = charge.delete(:id)
      @order.juno_charges.create!(charge)
    end

    def create_charge_payment(payment)
      charge = Juno::Charge.find_by(key: payment[:charge])
      payment.merge!(charge: charge)
      Juno::CreditCardPayment.create!(payment)
    end

    def set_payment_denied_error(message)
      @order.update!(status: :payment_denied)
      CheckoutMailer.with(order: @order).payment_error(message).deliver_later
    end

    def set_generic_error
      @order.update!(status: :processing_error)
      CheckoutMailer.with(order: @order).generic_error.deliver_later
    end
  end
end