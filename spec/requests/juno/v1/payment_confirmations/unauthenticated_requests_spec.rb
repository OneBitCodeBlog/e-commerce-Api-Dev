require "rails_helper"

RSpec.describe "Juno V1 Payment Confirmations", type: :request do  
  context "POST /payment_confirmations" do
    let(:url) { "/juno/v1/payment_confirmations" }
    let!(:order) { create(:order, status: :waiting_payment, payment_type: :billet) }
    let!(:juno_charges) { create(:juno_charge, order: order) }
    
    before(:each) { post url }
    
    include_examples "unauthenticated access"
  end
end