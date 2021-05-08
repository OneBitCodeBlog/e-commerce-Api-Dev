require "rails_helper"

describe Admin::AlocateLicensesService do
  context "when #call" do
    let!(:order) { create(:order) }
    let!(:line_item) { create(:line_item, order: order) }
    let!(:licenses) { create_list(:license, line_item.quantity, game: line_item.product.productable) }

    it "allocates same number of licenses as line item quantity" do
      expect do  
        described_class.new(line_item).call
      end.to change(line_item.licenses, :count).by(line_item.quantity)
    end

    it "licenses receives :in_use status" do
      described_class.new(line_item).call
      licenses_status = line_item.licenses.pluck(:status).uniq
      expect(licenses_status).to eq ['in_use']
    end
  end
end