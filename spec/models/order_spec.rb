require 'rails_helper'

RSpec.describe Order, type: :model do
  it { is_expected.to validate_presence_of(:status).on(:update) }
  it do 
    is_expected.to define_enum_for(:status).with_values({ 
      processing_order: 1, order_accepted: 2, processing_payment: 3, 
      payment_accepted: 4, payment_denied: 5, delivered: 6 
    })
  end
  it { is_expected.to validate_presence_of(:subtotal) }
  it { is_expected.to validate_numericality_of(:subtotal).is_greater_than(0) }
  it { is_expected.to validate_presence_of(:total_amount) }
  it { is_expected.to validate_numericality_of(:total_amount).is_greater_than(0) }
  it { is_expected.to validate_presence_of(:payment_type) }
  it { is_expected.to define_enum_for(:payment_type).with_values({ credit_card: 1, billet: 2 }) }
  it { is_expected.to validate_presence_of(:installments) }
  it { is_expected.to validate_numericality_of(:installments).only_integer.is_greater_than(0) }
  it { is_expected.to validate_presence_of(:document) }

  it { is_expected.to have_many :line_items }
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to(:coupon).optional }

  it "validates if :document is as CPF" do
    subject.document = "111.561.236-63"
    subject.validate
    expect(subject.errors).to have_key(:document)
  end

  it "validates if :document is as CNPJ" do
    subject.document = "34.123.754-0001/01"
    subject.validate
    expect(subject.errors).to have_key(:document)
  end

  it "#due_date must be 7 days ahead :created_at" do
    subject = create(:order)
    distance_days = (subject.due_date - subject.created_at) / 86400
    expect(distance_days).to eq 7
  end

  it "receives :pending_payment status as default on creation" do
    subject = create(:order, status: nil)
    expect(subject.status).to eq "processing_order"
  end

  context "when :payment_type is :credit_card" do
    it "validates :card_hash presence" do
      subject = build(:order, payment_type: :credit_card, card_hash: nil)
      subject.validate
      expect(subject.errors).to have_key(:card_hash)
    end

    it "validates :address presence" do
      subject = build(:order, payment_type: :credit_card, address: nil)
      subject.validate
      expect(subject.errors).to have_key(:address)
    end

    it "validates_associated :address" do
      subject = build(:order, payment_type: :credit_card, address: nil)
      subject.validate
      expect(subject.errors).to have_key(:address)
    end
  end
end
