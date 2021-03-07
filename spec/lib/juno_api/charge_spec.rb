require "rails_helper"
require_relative "../../../lib/juno_api/charge"

describe JunoApi::Charge do
  let!(:order) { create(:order) }

  describe "#create" do
    before(:each) do
      singleton = double(access_token: SecureRandom.hex)
      allow(JunoApi::Auth).to receive(:singleton).and_return(singleton)
    end

    context "with invalid params" do
      it "should raise an error" do
        error = { details: [{ message: "Some error", errorCode: "10000" }] }.to_json
        error_response = double(code: 400, body: error, parsed_response: JSON.parse(error))
        allow(JunoApi::Charge).to receive(:post).and_return(error_response)
        expect do
          described_class.new.create!(order)
        end.to raise_error(JunoApi::RequestError)
      end
    end

    context "with valid params" do
      let(:return_from_api) do
        installment_to_pay = (order.total_amount / order.installments).floor(2)
        charges = 0.upto(order.installments - 1).map do |num|
          { id: "000#{num}", code: num, dueDate: (order.due_date + num.months).strftime("%Y-%m-%d"),
            amount: installment_to_pay }
        end
        { _embedded: { charges: charges } }.to_json
      end

      before(:each) do
        api_response = double(code: 200, body: return_from_api, parsed_response: JSON.parse(return_from_api))
        allow(JunoApi::Charge).to receive(:post).and_return(api_response)
      end

      it "returns same quantity of charges as installments" do
        charges = described_class.new.create!(order)
        expect(charges.count).to eq order.installments
      end

      it "return all charges with same installment amout" do
        charges = described_class.new.create!(order)
        installment_amount = charges.map { |charge| charge[:amount] }.uniq
        expect(installment_amount.size).to eq 1
      end


      it "return right amount on each installment" do
        installment_for_payment = (order.total_amount / order.installments.to_f).floor(2).to_f
        charges = described_class.new.create!(order)
        charges.each do |charge| 
          expect(charge[:amount].to_f).to eq installment_for_payment
        end
      end
    end
  end
end