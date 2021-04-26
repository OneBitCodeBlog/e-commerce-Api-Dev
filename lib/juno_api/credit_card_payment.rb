require_relative "./auth"
require_relative "./request_error"

module JunoApi
  class CreditCardPayment
    include HTTParty

    base_uri "#{JUNO_RESOURCE_URL}/payments"

    headers 'Content-Type' => 'application/json' 
    headers 'X-Api-Version' => '2'
    headers 'X-Resource-Token' => Rails.application.credentials.juno[:private_token]

    def initialize
      @auth = Auth.singleton
    end
    
    def create!(order)
      auth_header = { 'Authorization' => "Bearer #{auth.access_token}" }
      body = prepare_create_body(order, order.juno_charges.first.key)
      response = self.class.post("/", headers: auth_header, body: body.to_json)
      raise_error(response) if response.code != 200
      organize_response(response)
    end

    private

    attr_reader :auth

    def prepare_create_body(order, charge_key)
      { 
        chargeId: charge_key,
        creditCardDetails: { creditCardHash: order.card_hash },
        billing: { email: order.user.email, address: build_address_attributes(order.address) }
      }
    end

    def raise_error(response) 
      details = response.parsed_response['details'].map { |detail| detail.transform_keys(&:underscore) }
      raise RequestError.new("Invalid request sent to Juno", details)
    rescue NoMethodError => e
      raise RequestError.new("Invalid request sent to Juno")
    end

    def organize_response(response)
      response.parsed_response['payments'].map do |payment|
        { 
          key: payment['id'], charge: payment['chargeId'], release_date: payment['releaseDate'], 
          status: payment['status'], reason: payment['failReason'] 
        }
      end
    end

    def build_address_attributes(address)
      address.attributes.transform_keys { |key| key.camelize(:lower) }
    end
  end
end