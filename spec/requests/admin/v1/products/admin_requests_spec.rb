require 'rails_helper'

RSpec.describe "Admin V1 Products as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /products" do
    let(:url) { "/admin/v1/products" }
    let!(:categories) { create_list(:category, 2) }
    let!(:products) { create_list(:product, 10, categories: categories) }

    context "without any params" do
      it "returns 10 records" do
        get url, headers: auth_header(user)
        expect(body_json['products'].count).to eq 10
      end
      
      it "returns Products with :productable following default pagination" do
        get url, headers: auth_header(user)
        expected_return = products[0..9].map do |product| 
          build_game_product_json(product)
        end
        expect(body_json['products']).to contain_exactly *expected_return
      end

      it "returns success status" do
        get url, headers: auth_header(user)
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total: 10, total_pages: 1 } do
        before { get url, headers: auth_header(user) }
      end
    end

    context "with search[name] param" do
      let!(:search_name_products) do
        products = [] 
        15.times { |n| products << create(:product, name: "Search #{n + 1}") }
        products 
      end

      let(:search_params) { { search: { name: "Search" } } }

      it "returns only seached products limited by default pagination" do
        get url, headers: auth_header(user), params: search_params
        expected_return = search_name_products[0..9].map do |product|
          build_game_product_json(product)
        end
        expect(body_json['products']).to contain_exactly *expected_return
      end

      it "returns success status" do
        get url, headers: auth_header(user), params: search_params
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total: 15, total_pages: 2 } do
        before { get url, headers: auth_header(user), params: search_params }
      end
    end

    context "with pagination params" do
      let(:page) { 2 }
      let(:length) { 5 }

      let(:pagination_params) { { page: page, length: length } }

      it "returns records sized by :length" do
        get url, headers: auth_header(user), params: pagination_params
        expect(body_json['products'].count).to eq length
      end
      
      it "returns products limited by pagination" do
        get url, headers: auth_header(user), params: pagination_params
        expected_return = products[5..9].map do |product|
          build_game_product_json(product)
        end
        expect(body_json['products']).to contain_exactly *expected_return
      end

      it "returns success status" do
        get url, headers: auth_header(user), params: pagination_params
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 2, length: 5, total: 10, total_pages: 2 } do
        before { get url, headers: auth_header(user), params: pagination_params }
      end
    end

    context "with order params" do
      let(:order_params) { { order: { name: 'desc' } } }

      it "returns ordered products limited by default pagination" do
        get url, headers: auth_header(user), params: order_params
        products.sort! { |a, b| b[:name] <=> a[:name] }
        expected_return = products[0..9].map do |product|
          build_game_product_json(product)
        end
        expect(body_json['products']).to contain_exactly *expected_return
      end
 
      it "returns success status" do
        get url, headers: auth_header(user), params: order_params
        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total: 10, total_pages: 1 } do
        before { get url, headers: auth_header(user), params: order_params }
      end
    end
  end

  context "POST /products" do
    let(:url) { "/admin/v1/products" }
    let(:categories) { create_list(:category, 2) }
    let(:system_requirement) { create(:system_requirement) }
    let(:post_header) { auth_header(user, merge_with: { 'Content-Type' => 'multipart/form-data' }) }
    
    context "with valid params" do
      let(:game_params) { attributes_for(:game, system_requirement_id: system_requirement.id) }
      let(:product_params) do 
        { product: attributes_for(:product).merge(category_ids: categories.map(&:id))
                                           .merge(productable: "game").merge(game_params) }
      end

      it 'adds a new Product' do
        expect do
          post url, headers: post_header, params: product_params
        end.to change(Product, :count).by(1)
      end

      it 'adds a new productable' do
        expect do
          post url, headers: post_header, params: product_params
        end.to change(Game, :count).by(1)
      end

      it 'associates categories to Product' do
        post url, headers: post_header, params: product_params
        expect(Product.last.categories.ids).to contain_exactly *categories.map(&:id)
      end

      it 'returns last added Product' do
        post url, headers: post_header, params: product_params
        expected_product = build_game_product_json(Product.last)
        expect(body_json['product']).to eq expected_product
      end

      it 'returns success status' do
        post url, headers: post_header, params: product_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid Product params" do
      let(:game_params) { attributes_for(:game, system_requirement_id: system_requirement.id) }
      let(:product_invalid_params) do 
        { product: attributes_for(:product, name: nil).merge(category_ids: categories.map(&:id))
                                                      .merge(productable: "game").merge(game_params) }
      end

      it 'does not add a new Product' do
        expect do
          post url, headers: post_header, params: product_invalid_params
        end.to_not change(Product, :count)
      end

      it 'does not add a new productable' do
        expect do
          post url, headers: post_header, params: product_invalid_params
        end.to_not change(Game, :count)
      end

      it 'does not create ProductCategory' do
        expect do
          post url, headers: post_header, params: product_invalid_params
        end.to_not change(ProductCategory, :count)
      end

      it 'returns error message' do
        post url, headers: post_header, params: product_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        post url, headers: post_header, params: product_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with invalid :productable params" do
      let(:game_params) { attributes_for(:game, developer: "", system_requirement_id: system_requirement.id) }
      let(:invalid_productable_params) do 
        { product: attributes_for(:product).merge(productable: "game").merge(game_params) }
      end

      it 'does not add a new Product' do
        expect do
          post url, headers: post_header, params: invalid_productable_params
        end.to_not change(Product, :count)
      end

      it 'does not add a new productable' do
        expect do
          post url, headers: post_header, params: invalid_productable_params
        end.to_not change(Game, :count)
      end

      it 'does not create ProductCategory' do
        expect do
          post url, headers: post_header, params: invalid_productable_params
        end.to_not change(ProductCategory, :count)
      end

      it 'returns error message' do
        post url, headers: post_header, params: invalid_productable_params
        expect(body_json['errors']['fields']).to have_key('developer')
      end

      it 'returns unprocessable_entity status' do
        post url, headers: post_header, params: invalid_productable_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "without :productable params" do
      let(:product_without_productable_params) do
        { product: attributes_for(:product).merge(category_ids: categories.map(&:id)) }
      end

      it 'does not add a new Product' do
        expect do
          post url, headers: post_header, params: product_without_productable_params
        end.to_not change(Product, :count)
      end

      it 'does not add a new productable' do
        expect do
          post url, headers: post_header, params: product_without_productable_params
        end.to_not change(Game, :count)
      end

      it 'does not create ProductCategory' do
        expect do
          post url, headers: post_header, params: product_without_productable_params
        end.to_not change(ProductCategory, :count)
      end

      it 'returns error message' do
        post url, headers: post_header, params: product_without_productable_params
        expect(body_json['errors']['fields']).to have_key('productable')
      end

      it 'returns unprocessable_entity status' do
        post url, headers: post_header, params: product_without_productable_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "GET /products/:id" do
    let(:product) { create(:product) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    it "returns requested Product" do
      get url, headers: auth_header(user)
      expected_product = build_game_product_json(product)
      expect(body_json['product']).to eq expected_product
    end

    it "returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "PATCH /products/:id" do
    let(:old_categories) { create_list(:category, 2) }
    let(:new_categories) { create_list(:category, 2) }
    let(:product) { create(:product, categories: old_categories) }
    let(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/products/#{product.id}" }
    let(:patch_header) { auth_header(user, merge_with: { 'Content-Type' => 'multipart/form-data' }) }

    context "with valid Product params" do
      let(:new_name) { 'New name' }
      let(:product_params) do 
        { product: attributes_for(:product, name: new_name).merge(category_ids: new_categories.map(&:id)) }
      end

      it 'updates Product' do
        patch url, headers: patch_header, params: product_params
        product.reload
        expect(product.name).to eq new_name
      end

      it 'updates to new categories' do
        patch url, headers: patch_header, params: product_params
        product.reload
        expect(product.categories.ids).to contain_exactly *new_categories.map(&:id)
      end

      it 'returns updated Product' do
        patch url, headers: patch_header, params: product_params
        product.reload
        expected_product = build_game_product_json(product)
        expect(body_json['product']).to eq expected_product
      end

      it 'returns success status' do
        patch url, headers: patch_header, params: product_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid Product params" do
      let(:product_invalid_params) do 
        { product: attributes_for(:product, name: nil).merge(category_ids: new_categories.map(&:id)) }
      end

      it 'does not update Product' do
        old_name = product.name
        patch url, headers: patch_header, params: product_invalid_params
        product.reload
        expect(product.name).to eq old_name
      end

      it 'keeps old categories' do
        patch url, headers: patch_header, params: product_invalid_params
        product.reload
        expect(product.categories.ids).to contain_exactly *old_categories.map(&:id)
      end

      it 'returns error message' do
        patch url, headers: patch_header, params: product_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        patch url, headers: patch_header, params: product_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with invalid :productable params" do
      let(:invalid_productable_params) do 
        { product: attributes_for(:game, developer: "") }
      end

      it 'does not update productable' do
        old_developer = product.productable.developer
        patch url, headers: patch_header, params: invalid_productable_params
        product.productable.reload
        expect(product.productable.developer).to eq old_developer
      end

      it 'returns error message' do
        patch url, headers: patch_header, params: invalid_productable_params
        expect(body_json['errors']['fields']).to have_key('developer')
      end

      it 'returns unprocessable_entity status' do
        patch url, headers: patch_header, params: invalid_productable_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "without :productable params" do
      let(:new_name) { 'New name' }
      let(:product_without_productable_params) do
        { product: attributes_for(:product, name: new_name).merge(category_ids: new_categories.map(&:id)) }
      end

      it 'updates Product' do
        patch url, headers: patch_header, params: product_without_productable_params
        product.reload
        expect(product.name).to eq new_name
      end

      it 'updates to new categories' do
        patch url, headers: patch_header, params: product_without_productable_params
        product.reload
        expect(product.categories.ids).to contain_exactly *new_categories.map(&:id)
      end

      it 'returns updated Product' do
        patch url, headers: patch_header, params: product_without_productable_params
        product.reload
        expected_product = build_game_product_json(product)
        expect(body_json['product']).to eq expected_product
      end

      it 'returns success status' do
        patch url, headers: patch_header, params: product_without_productable_params
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "DELETE /products/:id" do
    let(:productable) { create(:game) }
    let!(:product) { create(:product, productable: productable) }
    let(:url) { "/admin/v1/products/#{product.id}" }

    it 'removes Product' do
      expect do  
        delete url, headers: auth_header(user)
      end.to change(Product, :count).by(-1)
    end

    it 'removes productable' do
      expect do  
        delete url, headers: auth_header(user)
      end.to change(Game, :count).by(-1)
    end

    it 'returns success status' do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end

    it 'does not return any body content' do
      delete url, headers: auth_header(user)
      expect(body_json).to_not be_present
    end

    it 'removes all associated product categories' do
      product_categories = create_list(:product_category, 3, product: product)
      delete url, headers: auth_header(user)
      expected_product_categories = ProductCategory.where(id: product_categories.map(&:id))
      expect(expected_product_categories.count).to eq 0
    end

    it 'does not remove unassociated product categories' do
      product_categories = create_list(:product_category, 3)
      delete url, headers: auth_header(user)
      present_product_categories_ids = product_categories.map(&:id)
      expected_product_categories = ProductCategory.where(id: present_product_categories_ids)
      expect(expected_product_categories.ids).to contain_exactly(*present_product_categories_ids)
    end
  end
end

def build_game_product_json(product)
  json = product.as_json(only: %i(id name description price status))
  json['categories'] = product.categories.map(&:name)
  json['image_url'] = rails_blob_url(product.image)
  json['productable'] = product.productable_type.underscore
  json.merge product.productable.as_json(only: %i(mode release_date developer))
end