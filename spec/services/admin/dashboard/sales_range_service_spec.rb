require "rails_helper"

describe Admin::Dashboard::SalesRangeService do
  context "#call" do
    context "when range is less than 30 days" do
      let(:min_date) { 20.days.ago }
      let(:max_date) { Date.current }

      let(:product) { create(:product) }
      
      let!(:sales_line_items) do
        20.downto(1).map do |num|
          order = create(:order, created_at: num.days.ago)
          order.update_column(:status, :finished)
          create(:line_item, order: order, product: product, payed_price: 200, quantity: num)
        end
      end

      it "returns data grouped by day" do
        expected_return = sales_line_items.map do |line_item|
          day = line_item.order.created_at.strftime("%Y-%m-%d")
          total_sold = line_item.payed_price * line_item.quantity
          [day, total_sold]
        end.to_h
        service = described_class.new(min: min_date, max: max_date)
        service.call
        expect(service.records).to eq expected_return
      end
    end

    context "when range is greater than 30 days" do
      let(:min_date) { 5.months.ago }
      let(:max_date) { Date.current }

      let(:product) { create(:product) }
      
      let!(:sales_line_items) do
        5.downto(1).map do |num|
          order = create(:order, created_at: num.months.ago)
          order.update_column(:status, :finished)
          create(:line_item, order: order, product: product, payed_price: 200, quantity: num)
        end
      end

      it "returns data grouped by month" do
        expected_return = sales_line_items.map do |line_item|
          month = line_item.order.created_at.strftime("%Y-%m")
          total_sold = line_item.payed_price * line_item.quantity
          [month, total_sold]
        end.to_h
        service = described_class.new(min: min_date, max: max_date)
        service.call
        expect(service.records).to eq expected_return
      end
    end
  end

  def build_product(line_item)
    total_sold = line_item.quantity * line_item.payed_price
    product = line_item.product
    product_image = Rails.application.routes.url_helpers.rails_blob_path(product.image, only_path: false)
    { product: product.name, image: product_image, quantity: line_item.quantity, total_sold: total_sold }
  end
end