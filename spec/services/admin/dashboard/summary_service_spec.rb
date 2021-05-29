require "rails_helper"

describe Admin::Dashboard::SummaryService do
  let(:min_date) { 7.days.ago }
  let(:max_date) { Date.current }

  context "#call" do
    it "returns users count follwing range date" do
      users_to_count = create_list(:user, 10, created_at: 2.days.ago)
      users_out_of_range = create_list(:user, 5, created_at: 8.days.ago)
      service = described_class.new(min: min_date, max: max_date)
      service.call
      expect(service.records[:users]).to eq users_to_count.size
    end

    it "returns products count following range date" do
      products_to_count = create_list(:product, 10, created_at: 2.days.ago)
      products_out_of_range = create_list(:product, 5, created_at: 8.days.ago)
      service = described_class.new(min: min_date, max: max_date)
      service.call
      expect(service.records[:products]).to eq products_to_count.size
    end

    it "returns orders count following range date and order :finished status" do
      orders_to_count = create_list(:order, 10, created_at: 2.days.ago)
      orders_to_count.each { |order| order.update_column(:status, :finished) }
      unfinished_orders = create_list(:order, 7, created_at: 2.days.ago)
      orders_out_of_range = create_list(:order, 5, created_at: 8.days.ago)
      service = described_class.new(min: min_date, max: max_date)
      service.call
      expect(service.records[:orders]).to eq orders_to_count.size
    end

    it "returns profit following range date and order :finished status" do
      orders_to_sum = create_list(:order, 10, created_at: 2.days.ago, total_amount: 65.43)
      orders_to_sum.each { |order| order.update_column(:status, :finished) }
      unfinished_orders = create_list(:order, 7, created_at: 2.days.ago, total_amount: 76.12)
      orders_out_of_range = create_list(:order, 5, created_at: 8.days.ago, total_amount: 43.12)
      service = described_class.new(min: min_date, max: max_date)
      service.call
      expected_amount = orders_to_sum.sum(&:total_amount)
      expect(service.records[:profit]).to eq expected_amount
    end
  end
end