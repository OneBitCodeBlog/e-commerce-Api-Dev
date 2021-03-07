require_relative "./auth"
require_relative "./request_error"

module JunoApi
  class Charge
    include HTTParty

    PAYMENT_TYPE = { 'billet' => "BOLETO", 'credit_card' =>"CREDIT_CARD" }

    base_uri "#{JUNO_RESOURCE_URL}/charges"

    headers 'Content-Type' => 'application/json' 
    headers 'X-Api-Version' => '2'
    headers 'X-Resource-Token' => Rails.application.credentials.juno[:private_token]

    def initialize
      @auth = Auth.singleton
    end

    def create!(order)
      auth_header = { 'Authorization' => "Bearer #{auth.access_token}" }
      body = prepare_create_body(order)
      response = self.class.post("/", headers: auth_header, body: body.to_json)
      raise_error(response) if response.code != 200
      organize_response(response)
    end

    private

    attr_reader :auth, :auth_header

    def prepare_create_body(order)
      { 
        charge: build_charge(order),
        billing: { name: order.user.name, document: order.document, email: order.user.email }
      }
    end

    def raise_error(response)
      details = response.parsed_response['details'].map { |detail| detail.transform_keys(&:underscore) }
      raise RequestError.new("Invalid request sent to Juno", details)
    rescue => e
      raise RequestError.new("Invalid request sent to Juno")
    end

    def organize_response(response)
      response.parsed_response['_embedded']['charges'].map do |charge|
        charge.deep_transform_keys { |key| key.underscore.to_sym }
      end
    end

    def build_charge(order)
      { 
        description: "Order ##{order.id}", amount: order.total_amount, dueDate: order.due_date.strftime("%Y-%m-%d"),
        installments: order.installments, discountAmount: (order.coupon&.discount_value).to_f,
        paymentTypes: [PAYMENT_TYPE[order.payment_type]]
      }
    end
  end
end