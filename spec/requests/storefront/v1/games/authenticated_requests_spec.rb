require 'rails_helper'

RSpec.describe "Storefront V1 Games as authenticated user", type: :request do
  let(:user) { create(:user) }

  context "GET /games" do
    let(:url) { "/storefront/v1/games" }
    let!(:user_games) { create_list(:product, 3) }
    let!(:order) { create(:order, user: user) }
    let!(:line_items) do
      0.upto(2).map { |index| create(:line_item, order: order, product: user_games[index], quantity: 1) }
    end
    let!(:licenses) do 
      line_items.map { |line_item| create_list(:license, line_item.quantity, line_item: line_item) }
    end
    let!(:non_user_order) { create(:order) }
    let!(:non_user_line_items) { create_list(:line_item, 4, order: non_user_order, product: user_games.first) }
    let!(:non_user_licenses) do 
      non_user_line_items.map { |line_item| create_list(:license, line_item.quantity, line_item: line_item) }
    end

    it "returns all user games" do
      get url, headers: auth_header(user)
      expected_games = build_game_structure(user_games, line_items)
      expect(body_json['games']).to contain_exactly *expected_games 
    end

    it "does not return any non-user licenses" do
      get url, headers: auth_header(user)
      game = body_json['games'].select { |game| game['id'] == user_games.first.id }.first
      unexpected_licenses = non_user_line_items.map { |line_item| line_item.licenses.map(&:key) }.flatten
      expect(game['licenses']).to_not include *unexpected_licenses
    end

    it "returns success status" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  def build_game_structure(products, line_items) 
    products.map do |product|
      json = product.as_json(only: %i[id name description])
      json['image_url'] = rails_blob_url(product.image)
      json.merge! product.productable.as_json(only: %i[mode developer release_date])
      json['system_requirement'] = product.productable.system_requirement.as_json
      game_licenses = line_items.select { |line_item| line_item.product_id == product.id }.map(&:licenses).flatten
      json.merge!({ 'licenses' => game_licenses.map(&:key) })
      json
    end
  end
end