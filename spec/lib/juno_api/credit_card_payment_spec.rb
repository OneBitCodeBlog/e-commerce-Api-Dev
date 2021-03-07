require "rails_helper"
require_relative "../../../lib/juno_api/credit_card_payment"

describe JunoApi::CreditCardPayment do
  let!(:order) { create(:order) }

  describe "#create" do
    let!(:order) { create(:order) }
    let!(:charges) { create_list(:juno_charge, 5, order: order) }

    before(:each) do
      singleton = double(access_token: SecureRandom.hex)
      allow(JunoApi::Auth).to receive(:singleton).and_return(singleton)
    end

    context "with invalid params" do
      it "should raise an error" do
        error = { details: [{ message: "Some error", errorCode: "10000" }] }.to_json
        error_response = double(code: 400, body: error, parsed_response: JSON.parse(error))
        allow(JunoApi::CreditCardPayment).to receive(:post).and_return(error_response)
        expect do
          described_class.new.create!(order)
        end.to raise_error(JunoApi::RequestError)
      end
    end

    context "with valid params" do
      let(:return_from_api) do
        payments = charges.map.with_index do |charge, index|
          release_date = (Time.zone.now + index.months).strftime("%Y-%m-%d")
          { 
            id: "pay_000#{index}", chargeId: charge.key, date: Time.zone.now.strftime("%Y-%m-%d"), 
            releaseDate: release_date, amount: charge.amount.to_f, fee: 2, type: "INSTALLMENT_CREDIT_CARD", 
            status: "CONFIRMED", failReason: nil
          }
        end
        { transactionId: SecureRandom.hex, installments: charges.count, payments: payments }.to_json
      end

      before(:each) do
        api_response = double(code: 200, body: return_from_api, parsed_response: JSON.parse(return_from_api))
        allow(JunoApi::CreditCardPayment).to receive(:post).and_return(api_response)
      end

      it "returns same quantity of charges" do
        payments = described_class.new.create!(order)
        expect(payments.count).to eq charges.count
      end

      it "return spected payments hash" do
        expected_payments = charges.map.with_index do |charge, index|
          release_date = (Time.zone.now + index.months).strftime("%Y-%m-%d")
          { id: "pay_000#{index}", charge: charge.key, release_date: release_date, status: "CONFIRMED", reason: nil }
        end
        payments = described_class.new.create!(order)
        expect(payments).to eq expected_payments
      end
    end
  end
end