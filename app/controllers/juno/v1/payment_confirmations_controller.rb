module Juno::V1
  class PaymentConfirmationsController < ApplicationController
    include StaticTokenAuthenticatable
    
    def create
      if params.has_key?(:chargeCode)
        Juno::Charge.find_by(code: params[:chargeCode])&.order&.update(status: :payment_accepted)
      end
      head :ok
    end
  end
end