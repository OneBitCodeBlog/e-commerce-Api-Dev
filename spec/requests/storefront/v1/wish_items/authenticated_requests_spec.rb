require 'rails_helper'

RSpec.describe "Storefront V1 Categories as authenticated user", type: :request do
  let(:user) { create(:user, [:admin, :client].sample) }

  context "GET /wish_items" do
    let(:url) { "/storefront/v1/wish_items" }
    let!(:wish_items) { create_list(:wish_item, 10, user: user) }
      
    it "returns all Wish Items" do
      get url, headers: auth_header(user)
      expect(body_json['wish_items'].count).to eq 10
    end
    
    it "returns Wish Items ordered by Product name" do
      get url, headers: auth_header(user)
      ordered_wish_items = wish_items.sort { |a, b| a.product.name <=> b.product.name }
      expected_wish_items = ordered_wish_items[0..9].map do |wish_item|
        build_wish_item_json(wish_item)
      end
      expect(body_json['wish_items']).to contain_exactly *expected_wish_items
    end

    it "does not return any records out of user wish items" do
      another_users_wish_items = create_list(:wish_item, 5)
      get url, headers: auth_header(user)
      unexpected_wish_items = another_users_wish_items.map do |wish_item|
        build_wish_item_json(wish_item)
      end
      expect(body_json['wish_items']).to_not include *unexpected_wish_items
    end

    it "returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "POST /wish_items" do
    let!(:product) { create(:product) }
    let(:url) { "/storefront/v1/wish_items" }
    
    context "with valid params" do
      let(:wish_item_params) { { wish_item: { product_id: product.id } }.to_json }

      it 'adds a new Wish Item for authenticated user' do
        expect do
          post url, headers: auth_header(user), params: wish_item_params
        end.to change(user.wish_items, :count).by(1)
      end

      it 'returns last added Wish Item' do
        post url, headers: auth_header(user), params: wish_item_params
        expected_wish_item = build_wish_item_json(WishItem.last)
        expect(body_json['wish_item']).to eq expected_wish_item
      end

      it 'returns success status' do
        post url, headers: auth_header(user), params: wish_item_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:wish_item_invalid_params) do 
        { wish_item: { product_id: nil } }.to_json
      end

      it 'does not add a new Wish Item for authenticated user' do
        expect do
          post url, headers: auth_header(user), params: wish_item_invalid_params
        end.to_not change(user.wish_items, :count)
      end

      it 'returns error message' do
        post url, headers: auth_header(user), params: wish_item_invalid_params
        expect(body_json['errors']['fields']).to have_key('product')
      end

      it 'returns unprocessable_entity status' do
        post url, headers: auth_header(user), params: wish_item_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "DELETE /wish_items/:id" do
    context "when trying to remove own with item" do
      let!(:wish_item) { create(:wish_item, user: user) }
      let(:url) { "/storefront/v1/wish_items/#{wish_item.id}" }

      it 'removes Wish Item' do
        expect do  
          delete url, headers: auth_header(user)
        end.to change(user.wish_items, :count).by(-1)
      end

      it 'returns success status' do
        delete url, headers: auth_header(user)
        expect(response).to have_http_status(:no_content)
      end

      it 'does not return any body content' do
        delete url, headers: auth_header(user)
        expect(body_json).to_not be_present
      end
    end

    it "returns :not_found when trying to remove another user Wish Item" do
      another_user_wish_item = create(:wish_item)
      url = "/storefront/v1/wish_items/#{another_user_wish_item.id}"
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:not_found)
    end
  end

  def build_wish_item_json(wish_item)
    json = { 'id' => wish_item.id }
    json.merge! wish_item.product.as_json(only: %i(name description))
    json['price'] = wish_item.product.price.to_f
    json['image_url'] = rails_blob_url(wish_item.product.image)
    json['categories'] = wish_item.product.categories.map(&:name)
    json
  end
end