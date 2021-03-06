require_relative "./auth.rb"

module JunoApi
  class Charge
    class RequestError < StandardError; end

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
      raise RequestError.new("Invalid data sent to Juno") if response.code != 200
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