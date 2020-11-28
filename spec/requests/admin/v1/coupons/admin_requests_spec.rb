require 'rails_helper'

RSpec.describe "Admin V1 Coupons as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /coupons" do
    let(:url) { "/admin/v1/coupons" }
    let!(:coupons) { create_list(:coupon, 10) }
    
    context "without any params" do
      it "returns 10 coupons" do
        get url, headers: auth_header(user)
        expect(body_json['coupons'].count).to eq 10
      end
      
      it "returns 10 first Coupons" do
        get url, headers: auth_header(user)
        expected_coupons = coupons[0..9].as_json(only: %i(id name code status discount_value due_date))
        expect(body_json['coupons']).to contain_exactly *expected_coupons
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
      let!(:search_name_coupons) do
        coupons = [] 
        15.times { |n| coupons << create(:coupon, name: "Search #{n + 1}") }
        coupons 
      end

      let(:search_params) { { search: { name: "Search" } } }

      it "returns only searched coupons limited by default pagination" do
        get url, headers: auth_header(user), params: search_params
        expected_coupons = search_name_coupons[0..9].map do |coupon|
          coupon.as_json(only: %i(id name code status discount_value due_date))
        end
        expect(body_json['coupons']).to contain_exactly *expected_coupons
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
        expect(body_json['coupons'].count).to eq length
      end
      
      it "returns coupons limited by pagination" do
        get url, headers: auth_header(user), params: pagination_params
        expected_coupons = coupons[5..9].as_json(only: %i(id name code status discount_value due_date))
        expect(body_json['coupons']).to contain_exactly *expected_coupons
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

      it "returns ordered coupons limited by default pagination" do
        get url, headers: auth_header(user), params: order_params
        coupons.sort! { |a, b| b[:name] <=> a[:name]}
        expected_coupons = coupons[0..9].as_json(only: %i(id name code status discount_value due_date))
        expect(body_json['coupons']).to contain_exactly *expected_coupons
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

  context "POST /coupons" do
    let(:url) { "/admin/v1/coupons" }
    
    context "with valid params" do
      let(:coupon_params) { { coupon: attributes_for(:coupon) }.to_json }

      it 'adds a new Coupon' do
        expect do
          post url, headers: auth_header(user), params: coupon_params
        end.to change(Coupon, :count).by(1)
      end

      it 'returns last added Coupon' do
        post url, headers: auth_header(user), params: coupon_params
        expected_coupon = Coupon.last.as_json(only: %i(id name code status discount_value due_date))
        expect(body_json['coupon']).to eq expected_coupon
      end

      it 'returns success status' do
        post url, headers: auth_header(user), params: coupon_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:coupon_invalid_params) do 
        { coupon: attributes_for(:coupon, name: nil) }.to_json
      end

      it 'does not add a new Coupon' do
        expect do
          post url, headers: auth_header(user), params: coupon_invalid_params
        end.to_not change(Coupon, :count)
      end

      it 'returns error message' do
        post url, headers: auth_header(user), params: coupon_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        post url, headers: auth_header(user), params: coupon_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "GET /coupons/:id" do
    let(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }

    it "returns requested Coupon" do
      get url, headers: auth_header(user)
      expected_coupon = coupon.as_json(only: %i(id name code status discount_value due_date))
      expect(body_json['coupon']).to eq expected_coupon
    end

    it "returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "PATCH /coupons/:id" do
    let(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }

    context "with valid params" do
      let(:new_name) { 'My new Coupon' }
      let(:coupon_params) { { coupon: { name: new_name } }.to_json }

      it 'updates Coupon' do
        patch url, headers: auth_header(user), params: coupon_params
        coupon.reload
        expect(coupon.name).to eq new_name
      end

      it 'returns updated Coupon' do
        patch url, headers: auth_header(user), params: coupon_params
        coupon.reload
        expected_coupon = coupon.as_json(only: %i(id name code status discount_value due_date))
        expect(body_json['coupon']).to eq expected_coupon
      end

      it 'returns success status' do
        patch url, headers: auth_header(user), params: coupon_params
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:coupon_invalid_params) do 
        { coupon: attributes_for(:coupon, name: nil) }.to_json
      end

      it 'does not update Coupon' do
        old_name = coupon.name
        patch url, headers: auth_header(user), params: coupon_invalid_params
        coupon.reload
        expect(coupon.name).to eq old_name
      end

      it 'returns error message' do
        patch url, headers: auth_header(user), params: coupon_invalid_params
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entity status' do
        patch url, headers: auth_header(user), params: coupon_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "DELETE /coupons/:id" do
    let!(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }

    it 'removes Coupon' do
      expect do  
        delete url, headers: auth_header(user)
      end.to change(Coupon, :count).by(-1)
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
end
