require "rails_helper"

RSpec.describe "Storefront V1 Home", type: :request do
  context "GET /products" do
    let(:url) { "/storefront/v1/products" }
    let!(:general_products) { create_list(:product, 15) }

    context "without any params" do
      it "returns 10 records" do
        get url, headers: unauthenticated_header
        expect(body_json['products'].count).to eq 10
      end
      
      it "returns Products with :productable following default pagination" do
        get url, headers: unauthenticated_header
        expected_return = general_products[0..9].map do |product| 
          build_game_product_json(product)
        end
        expect(body_json['products']).to eq expected_return
      end

      it "returns success status" do
        get url, headers: unauthenticated_header
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total: 15, total_pages: 2 } do
        before { get url, headers: unauthenticated_header }
      end
    end

    context "with search param" do
      let!(:search_products) do
        products = [] 
        3.times { |n| products << create(:product, name: "Search #{n + 1}") }
        3.times { |n| products << create(:product, description: "Some kind of search #{n + 1}") }
        3.times do |n|
          game = create(:game, developer: "Search #{n + 1}")
          products << create(:product, productable: game)
        end
        products 
      end

      let(:search_params) { { search: "Search" } } 

      it "returns only seached products limited by default pagination" do
        get url, headers: unauthenticated_header, params: search_params
        expected_return = search_products[0..8].map do |product|
          build_game_product_json(product)
        end
        expect(body_json['products']).to contain_exactly *expected_return
      end

      it "does not return any product out of search" do
        get url, headers: unauthenticated_header, params: search_params
        unexpected_return = general_products.map do |product|
          build_game_product_json(product)
        end
        expect(body_json['products']).to_not include *unexpected_return
      end

      it "returns success status" do
        get url, headers: unauthenticated_header, params: search_params
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 1, length: 9, total: 9, total_pages: 1 } do
        before { get url, headers: unauthenticated_header, params: search_params }
      end
    end

    context "with categories filter" do
      let!(:categories) { create_list(:category, 3) }
      let!(:categories_products) { create_list(:product, 15, category_ids: categories.map(&:id).sample(2)) }

      let(:search_params) { { category_ids: categories.map(&:id) } }

      it "returns only search ategorized products limited by default pagination" do
        get url, headers: unauthenticated_header, params: search_params
        expected_return = categories_products[0..9].map do |product|
          build_game_product_json(product)
        end
        expect(body_json['products']).to contain_exactly *expected_return
      end

      it "does not return any product out of search" do
        get url, headers: unauthenticated_header, params: search_params
        unexpected_return = general_products.map do |product|
          build_game_product_json(product)
        end
        expect(body_json['products']).to_not include *unexpected_return
      end

      it "returns success status" do
        get url, headers: unauthenticated_header, params: search_params
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total: 15, total_pages: 2 } do
        before { get url, headers: unauthenticated_header, params: search_params }
      end
    end

    context "with price filter" do
      let!(:lower_prices_products) do 
        products = []
        5.times { |n| products << create(:product, price: Faker::Commerce.price(range: 10.0...30.0)) }
        products
      end

      let!(:higher_price_products) do 
        products = []
        5.times { |n| products << create(:product, price: Faker::Commerce.price(range: 30.0..50.0)) }
        products
      end

      context "only :min fulfilled" do
        let(:search_params) { { price: { min: 30.0 } } }

        it "returns only products with minimal prices limited by default pagination" do
          get url, headers: unauthenticated_header, params: search_params
          expected_return = (general_products + higher_price_products)[0..9].map do |product|
            build_game_product_json(product)
          end
          expect(body_json['products']).to contain_exactly *expected_return
        end

        it "does not return any product out of search" do
          get url, headers: unauthenticated_header, params: search_params
          unexpected_return = lower_prices_products.map do |product|
            build_game_product_json(product)
          end
          expect(body_json['products']).to_not include *unexpected_return
        end

        it "returns success status" do
          get url, headers: unauthenticated_header, params: search_params
          expect(response).to have_http_status(:ok)
        end

        it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total: 20, total_pages: 2 } do
          before { get url, headers: unauthenticated_header, params: search_params }
        end
      end

      context "only :max fulfilled" do
        let(:search_params) { { price: { max: 30.0 } } }

        it "returns only products with maximum prices limited by default pagination" do
          get url, headers: unauthenticated_header, params: search_params
          expected_return = lower_prices_products.map do |product|
            build_game_product_json(product)
          end
          expect(body_json['products']).to contain_exactly *expected_return
        end

        it "does not return any product out of search" do
          get url, headers: unauthenticated_header, params: search_params
          unexpected_return = (general_products + higher_price_products).map do |product|
            build_game_product_json(product)
          end
          expect(body_json['products']).to_not include *unexpected_return
        end

        it "returns success status" do
          get url, headers: unauthenticated_header, params: search_params
          expect(response).to have_http_status(:ok)
        end

        it_behaves_like 'pagination meta attributes', { page: 1, length: 5, total: 5, total_pages: 1 } do
          before { get url, headers: unauthenticated_header, params: search_params }
        end
      end

      context "both :min and :max fulfilled" do
        let(:search_params) { { price: { min: 10.0, max: 50.0 } } }

        it "returns only products in price range limited by default pagination" do
          get url, headers: unauthenticated_header, params: search_params
          expected_return = (lower_prices_products + higher_price_products).map do |product|
            build_game_product_json(product)
          end
          expect(body_json['products']).to contain_exactly *expected_return
        end

        it "does not return any product out of search" do
          get url, headers: unauthenticated_header, params: search_params
          unexpected_return = general_products.map do |product|
            build_game_product_json(product)
          end
          expect(body_json['products']).to_not include *unexpected_return
        end

        it "returns success status" do
          get url, headers: unauthenticated_header, params: search_params
          expect(response).to have_http_status(:ok)
        end

        it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total: 10, total_pages: 1 } do
          before { get url, headers: unauthenticated_header, params: search_params }
        end
      end
    end

    context "with release_date filter" do
      let!(:recently_released_products) do 
        products = []
        5.times do |n| 
          game = create(:game, release_date: (0..7).to_a.sample.days.ago)
          products << create(:product, productable: game)
        end
        products
      end

      let!(:older_products) do 
        products = []
        5.times do |n| 
          game = create(:game, release_date: (8..14).to_a.sample.days.ago)
          products << create(:product, productable: game)
        end
        products
      end

      context "only :min fulfilled" do
        let(:search_params) { { release_date: { min: 7.days.ago } } }

        it "returns only products with minimal released date limited by default pagination" do
          get url, headers: unauthenticated_header, params: search_params
          expected_return = recently_released_products.map do |product|
            build_game_product_json(product)
          end
          expect(body_json['products']).to match_array expected_return
        end

        it "does not return any product out of search" do
          get url, headers: unauthenticated_header, params: search_params
          unexpected_return = (older_products + general_products).map do |product|
            build_game_product_json(product)
          end
          expect(body_json['products']).to_not include *unexpected_return
        end

        it "returns success status" do
          get url, headers: unauthenticated_header, params: search_params
          expect(response).to have_http_status(:ok)
        end

        it_behaves_like 'pagination meta attributes', { page: 1, length: 5, total: 5, total_pages: 1 } do
          before { get url, headers: unauthenticated_header, params: search_params }
        end
      end

      context "only :max fulfilled" do
        let(:search_params) { { release_date: { max: 8.days.ago } } }

        it "returns only products with maximum release date limited by default pagination" do
          get url, headers: unauthenticated_header, params: search_params
          expected_return = (general_products + older_products)[0..9].map do |product|
            build_game_product_json(product)
          end
          expect(body_json['products']).to contain_exactly *expected_return
        end

        it "does not return any product out of search" do
          get url, headers: unauthenticated_header, params: search_params
          unexpected_return = recently_released_products.map do |product|
            build_game_product_json(product)
          end
          expect(body_json['products']).to_not include *unexpected_return
        end

        it "returns success status" do
          get url, headers: unauthenticated_header, params: search_params
          expect(response).to have_http_status(:ok)
        end

        it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total: 20, total_pages: 2 } do
          before { get url, headers: unauthenticated_header, params: search_params }
        end
      end

      context "both :min and :max fulfilled" do
        let(:search_params) { { release_date: { min: 14.days.ago, max: Time.now } } }

        it "returns only products in release date range limited by default pagination" do
          get url, headers: unauthenticated_header, params: search_params
          expected_return = (recently_released_products + older_products).map do |product|
            build_game_product_json(product)
          end
          expect(body_json['products']).to contain_exactly *expected_return
        end

        it "does not return any product out of search" do
          get url, headers: unauthenticated_header, params: search_params
          unexpected_return = general_products.map do |product|
            build_game_product_json(product)
          end
          expect(body_json['products']).to_not include *unexpected_return
        end

        it "returns success status" do
          get url, headers: unauthenticated_header, params: search_params
          expect(response).to have_http_status(:ok)
        end

        it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total: 10, total_pages: 1 } do
          before { get url, headers: unauthenticated_header, params: search_params }
        end
      end
    end

    context "with pagination params" do
      let(:page) { 2 }
      let(:length) { 5 }

      let(:pagination_params) { { page: page, length: length } }

      it "returns records sized by :length" do
        get url, headers: unauthenticated_header, params: pagination_params
        expect(body_json['products'].count).to eq length
      end
      
      it "returns products limited by pagination" do
        get url, headers: unauthenticated_header, params: pagination_params
        expected_return = general_products[5..9].map do |product|
          build_game_product_json(product)
        end
        expect(body_json['products']).to contain_exactly *expected_return
      end

      it "returns success status" do
        get url, headers: unauthenticated_header, params: pagination_params
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 2, length: 5, total: 15, total_pages: 3 } do
        before { get url, headers: unauthenticated_header, params: pagination_params }
      end
    end

    context "with order params" do
      context "by price" do
        let(:order_params) { { order: { price: 'desc' } } }

        it "returns ordered products limited by default pagination" do
          get url, headers: unauthenticated_header, params: order_params
          general_products.sort! { |a, b| b[:price] <=> a[:price] }
          expected_return = general_products[0..9].map do |product|
            build_game_product_json(product)
          end
          expect(body_json['products']).to contain_exactly *expected_return
        end
  
        it "returns success status" do
          get url, headers: unauthenticated_header, params: order_params
          expect(response).to have_http_status(:ok)
        end

        it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total: 15, total_pages: 2 } do
          before { get url, headers: unauthenticated_header, params: order_params }
        end
      end

      context "by release date" do
        let(:order_params) { { order: { release_date: 'desc' } } }

        it "returns ordered products limited by default pagination" do
          get url, headers: unauthenticated_header, params: order_params
          general_products.sort! { |a, b| b[:release_date] <=> a[:release_date] }
          expected_return = general_products[0..9].map do |product|
            build_game_product_json(product)
          end
          expect(body_json['products']).to contain_exactly *expected_return
        end
  
        it "returns success status" do
          get url, headers: unauthenticated_header, params: order_params
          expect(response).to have_http_status(:ok)
        end

        it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total: 15, total_pages: 2 } do
          before { get url, headers: unauthenticated_header, params: order_params }
        end
      end
    end
  end

  def build_game_product_json(product)
    json = product.as_json(only: %i(id name description))
    json['price'] = product.price.to_f
    json['image_url'] = rails_blob_url(product.image)
    json['categories'] = product.categories.map(&:name)
    json
  end
end