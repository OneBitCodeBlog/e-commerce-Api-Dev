require "rails_helper"

describe Admin::Dashboard::TopFiveProductsService do
  let(:min_date) { 7.days.ago }
  let(:max_date) { Date.current }

  context "#call" do
    let(:top_five_products) { create_list(:product, 5) }
    let(:less_sold_products) { create_list(:product, 5) }
    let(:order) do 
      order = create(:order, created_at: 4.days.ago)
      order.update_column(:status, :finished)
      order
    end
    let!(:top_five_line_itens) do
      top_five_products.map.with_index do |product, index|
        create(:line_item, payed_price: 200, quantity: (index + 1), order: order, product: product)
      end
    end
    let(:out_of_date_order) do 
      order = create(:order, created_at: 8.days.ago)
      order.update_column(:status, :finished)
      order
    end
    let!(:out_of_date_line_items) do
      less_sold_products.map.with_index do |product, index|
        create(:line_item, payed_price: 2000, quantity: (index + 1), order: out_of_date_order, product: product)
      end
    end

    it "returns right sold products follwing range date" do
      expected_return = top_five_line_itens.reverse.map do |line_item|
        build_product(line_item)
      end
      service = described_class.new(min: min_date, max: max_date)
      service.call
      expect(service.records).to eq expected_return
    end

    it "does not return any product out of range date" do
      unexpected_return = out_of_date_line_items.reverse.map do |line_item|
        build_product(line_item)
      end
      service = described_class.new(min: min_date, max: max_date)
      service.call
      expect(service.records).to_not include *unexpected_return
    end
  end

  def build_product(line_item)
    total_sold = line_item.quantity * line_item.payed_price
    product = line_item.product
    product_image = Rails.application.routes.url_helpers.rails_blob_path(product.image, only_path: false)
    { product: product.name, image: product_image, quantity: line_item.quantity, total_sold: total_sold }
  end
end