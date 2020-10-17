require 'rails_helper'

RSpec.describe Admin::ProductSavingService, type: :model do
  context "when #call" do
    context "sending loaded product" do
      let!(:product) { create(:product) }
      
      context "with valid params" do
        let!(:game) { product.productable }
        let(:params) { { name: "New product", developer: "New company" } }

        it "updates product" do
          service = described_class.new(params, product)
          service.call
          product.reload
          expect(product.name).to eq "New product"
        end

        it "updates :productable" do
          service = described_class.new(params, product)
          service.call
          game.reload
          expect(game.developer).to eq "New company"
        end
      end

      context "with invalid :product params" do
        let(:product_params) { attributes_for(:product, name: "") }
  
        it "raises NotSavedProductError" do
          expect {
            service = described_class.new(product_params, product)
            service.call
          }.to raise_error(Admin::ProductSavingService::NotSavedProductError)
        end

        it "sets validation :errors" do
          service = error_proof_call(product_params, product)
          expect(service.errors).to have_key(:name)
        end
  
        it "doesn't update :product" do
          expect {  
            error_proof_call(product_params, product)
            product.reload
          }.to_not change(product, :name)
        end
      end
  
      context "with invalid :productable params" do
        let(:game_params) { attributes_for(:game, developer: "") }

        it "raises NotSavedProductError" do
          expect {
            service = described_class.new(game_params, product)
            service.call
          }.to raise_error(Admin::ProductSavingService::NotSavedProductError)
        end

        it "sets validation :errors" do
          service = error_proof_call(game_params, product)
          expect(service.errors).to have_key(:developer)
        end
        
        it "doesn't update :productable" do
          expect {  
            error_proof_call(game_params, product)
            product.productable.reload
          }.to_not change(product.productable, :developer)
        end
      end
    end
    
    context "without loaded product" do
      let!(:system_requirement) { create(:system_requirement) }

      context "with valid params" do
        let(:game_params) { attributes_for(:game, system_requirement_id: system_requirement.id) }
        let(:product_params) { attributes_for(:product, productable: "game") }
        let(:params) { product_params.merge(game_params) }
      
        it "creates a new product" do
          expect {
            service = described_class.new(params)
            service.call
          }.to change(Product, :count).by(1)
        end

        it "creates :productable" do
          expect {
            service = described_class.new(params)
            service.call
          }.to change(Game, :count).by(1)
        end

        it "sets created product" do
          service = described_class.new(params)
          service.call
          expect(service.product).to be_kind_of(Product)
        end
      end

      context "with invalid :product params" do
        let(:product_params) { attributes_for(:product, name: "", productable: "game") }
        let(:game_params) { attributes_for(:game, system_requirement_id: system_requirement.id) }
        let(:params) { product_params.merge(game_params) }

        it "raises NotSavedProductError" do
          expect {
            service = described_class.new(params)
            service.call
          }.to raise_error(Admin::ProductSavingService::NotSavedProductError)
        end

        it "sets validation :errors" do
          service = error_proof_call(params)
          expect(service.errors).to have_key(:name)
        end

        it "does not create a new product" do
          expect {
            error_proof_call(params)
          }.to_not change(Product, :count)
        end

        it "does not create a :productable" do
          expect {
            error_proof_call(params)
          }.to_not change(Game, :count)
        end
      end

      context "with invalid :productable params" do
        let(:product_params) { attributes_for(:product, productable: "Game") }
        let(:game_params) { attributes_for(:game, developer: "", system_requirement_id: system_requirement.id) }
        let(:params) { product_params.merge(game_params) }

        it "raises NotSavedProductError" do
          expect {
            service = described_class.new(params)
            service.call
          }.to raise_error(Admin::ProductSavingService::NotSavedProductError)
        end

        it "sets validation :errors" do
          service = error_proof_call(params)
          expect(service.errors).to have_key(:developer)
        end

        it "does not create a new product" do
          expect {
            error_proof_call(params)
          }.to_not change(Product, :count)
        end

        it "does not create a :productable" do
          expect {
            error_proof_call(params)
          }.to_not change(Game, :count)
        end
      end

      context "without :productable params" do
        let(:product_params) { attributes_for(:product) }

        it "raises NotSavedProductError" do
          expect {
            service = described_class.new(product_params)
            service.call
          }.to raise_error(Admin::ProductSavingService::NotSavedProductError)
        end

        it "does not create a new product" do
          expect {
            error_proof_call(product_params)
          }.to_not change(Product, :count)
        end

        it "sets validation :errors" do
          service = error_proof_call(product_params)
          expect(service.errors).to have_key(:productable)
        end

        it "does not create a :productable" do
          expect {
            error_proof_call(product_params)
          }.to_not change(Game, :count)
        end
      end
    end
  end
end

def error_proof_call(*params)
  service = described_class.new(*params)
  begin
    service.call
  rescue => e
  end
  return service
end