require 'rails_helper'

RSpec.describe LineItem, type: :model do
  it { is_expected.to validate_presence_of :quantity }
  it { is_expected.to validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
  it { is_expected.to validate_presence_of :payed_price }
  it { is_expected.to validate_numericality_of(:payed_price).is_greater_than(0) }
  it { is_expected.to validate_presence_of(:status).on(:update) }
  it { is_expected.to define_enum_for(:status).with_values(waiting_order: 1, preparing: 2, en_route: 3, delivered: 4) }

  it { is_expected.to belong_to :order }
  it { is_expected.to belong_to :product }
  it { is_expected.to have_many :licenses }

  it "receives :waiting_order status as default on creation" do
    subject = create(:line_item, status: nil)
    expect(subject.status).to eq 'waiting_order'
  end

  it "#total must be :payed_price multiplied by :quantity" do
    payed_price = 153.32
    quantity = 2
    subject = build(:line_item, payed_price: payed_price, quantity: quantity)
    expected_value = payed_price * quantity
    expect(subject.total).to eq expected_value
  end

  context "when #ship!" do
    it "sets line item with :processing status" do
      subject = create(:line_item)
      subject.ship!
      subject.reload
      expect(subject.status).to eq 'preparing'
    end

    it "#forwards to :productable #ship! method" do
      line_item = create(:line_item)
      productable = line_item.product.productable
      expect(productable).to receive(:ship!).with(line_item)
      line_item.ship!
    end
  end
end
