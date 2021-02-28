module Juno
  class Auth
    include HTTParty

    PATH = "/authorization-server/oauth/token"
    SECONDS_TO_WAIT_PROCESSING = 0.5
    LIMIT_RATE_TO_RENEW = 90

    base_uri "#{JUNO_BASE_URL}"

    attr_reader :access_token, :expires_in, :request_time
    private_class_method :new

    def self.singleton
      wait_until_process_is_done
      check_instance
      @instance
    end

    private

    attr_writer :access_token, :expires_in

    def self.wait_until_process_is_done
      while @processing
        sleep SECONDS_TO_WAIT_PROCESSING
      end
    end

    def self.check_instance
      if @instance.blank? || is_about_to_expire?(@instance)
        @processing = true
        @instance = new
        @processing = false
      end
    end

    def self.is_about_to_expire?(instance)
      expiration_rate = LIMIT_RATE_TO_RENEW / 100.0
      instance.request_time + instance.expires_in * expiration_rate < Time.zone.now
    end

    def initialize
      auth = process_auth!
      @access_token = auth['access_token']
      @expires_in = auth['expires_in']
      @request_time = Time.zone.now
    end

    def process_auth!
      body = { grant_type: 'client_credentials' }
      response = self.class.post(PATH, headers: { 'Authorization' => 'Basic ' + auth_token }, body: body )
      raise Error.new("Bad request") if response.code != 200
      response.parsed_response
    end

    def auth_token
      auth_data = Rails.application.credentials.juno.slice(:client, :secret)
      Base64.strict_encode64(auth_data[:client] + ":" + auth_data[:secret])
    end
  end
end