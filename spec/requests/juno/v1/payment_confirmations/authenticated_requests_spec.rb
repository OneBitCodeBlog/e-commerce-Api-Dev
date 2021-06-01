require "rails_helper"

RSpec.describe "Juno V1 Payment Confirmations without authentication", type: :request do  
  context "POST /payment_confirmations" do
    let(:token) { Rails.application.credentials.token[:auth] }
    let(:url) { "/juno/v1/payment_confirmations?token=#{token}" }
    let!(:order) { create(:order, status: :waiting_payment, payment_type: :billet) }
    let!(:juno_charges) { create(:juno_charge, order: order) }
    
    context "when 'chargeCode' param is present" do
      let(:params) do 
        { 'paymentToken' => SecureRandom.hex, 'chargeReference' => '', 'chargeCode' => juno_charges.code }
      end

      it "sets order with :payment_accepted status" do
        post url, headers: unauthenticated_header, params: params.to_json
        order.reload
        expect(order.status).to eq 'payment_accepted'
      end

      it "returns :ok status" do
        post url, headers: unauthenticated_header, params: params.to_json
        expect(response).to have_http_status(:ok)
      end
    end

    context "when 'chargeCode' param does not exist" do
      let(:params) do 
        { 'paymentToken' => SecureRandom.hex, 'chargeReference' => '', 'chargeCode' => 'some_random_code' }
      end

      it "keep order with same status" do
        post url, headers: unauthenticated_header, params: params.to_json
        old_status = order.status
        order.reload
        expect(order.status).to eq old_status
      end

      it "returns :ok status" do
        post url, headers: unauthenticated_header, params: params.to_json
        expect(response).to have_http_status(:ok)
      end
    end

    context "when 'chargeCode' param is not present" do
      let(:params) { { 'someOtherParam' => 'some_param_value' } }    

      it "keep order with same status" do
        post url, headers: unauthenticated_header, params: params.to_json
        old_status = order.status
        order.reload
        expect(order.status).to eq old_status
      end

      it "returns :ok status" do
        post url, headers: unauthenticated_header, params: params.to_json
        expect(response).to have_http_status(:ok)
      end
    end
  end
end