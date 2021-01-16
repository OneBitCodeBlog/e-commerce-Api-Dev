require "rails_helper"

describe Storefront::HomeLoaderService do
  context "when #call" do
    let!(:unavailable_products) do
      products = []
      5.times do
        game = create(:game, release_date: 2.days.ago)
        products << create(:product, productable: game, price: 5.00, status: :unavailable)
      end
      products
    end
    
    context "on featured procucts" do
      let!(:non_featured_products) { create_list(:product, 5, featured: false) }
      let!(:featured_products) { create_list(:product, 5) }

      it "returns 4 records" do
        service = described_class.new
        service.call
        expect(service.featured.count).to eq 4
      end

      it "returns random featured available products" do
        service = described_class.new
        service.call
        expect(service.featured).to satisfy do |expected_products| 
          expected_products & featured_products == expected_products
        end 
      end

      it "does not return unavailable or non-featured products" do
        service = described_class.new
        service.call
        expect(service.featured).to_not include(unavailable_products, non_featured_products)
      end
    end

    context "on recently released procucts" do
      let!(:non_last_release_products) do
        products = []
        5.times do
          game = create(:game, release_date: 8.days.ago)
          products << create(:product, productable: game)
        end
        products
      end

      let!(:last_release_products) do
        products = []
        5.times do
          game = create(:game, release_date: 2.days.ago)
          products << create(:product, productable: game)
        end
        products
      end

      it "returns 4 records" do
        service = described_class.new
        service.call
        expect(service.last_releases.count).to eq 4
      end

      it "returns random last released available products" do
        service = described_class.new
        service.call
        expect(service.last_releases).to satisfy do |expected_products| 
          expected_products & last_release_products == expected_products
        end 
      end

      it "does not return non-last released or unavailable products" do
        service = described_class.new
        service.call
        expect(service.last_releases).to_not include(unavailable_products, non_last_release_products)
      end
    end

    context "on cheapest procucts" do
      let!(:non_cheapest) { create_list(:product, 5, price: 110.00) }
      let!(:cheapest_products) { create_list(:product, 5, price: 5.00) }

      it "returns 4 records" do
        service = described_class.new
        service.call
        expect(service.cheapest.count).to eq 4
      end

      it "returns cheapest available products" do
        service = described_class.new
        service.call
        expect(service.cheapest).to satisfy do |expected_products| 
          expected_products & cheapest_products == expected_products
        end 
      end

      it "returns non-cheapest or unavailable products" do
        service = described_class.new
        service.call
        expect(service.cheapest).to_not include(unavailable_products, non_cheapest)
      end
    end
  end
end