require 'rails_helper'

RSpec.describe Coupon, type: :model do
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :code }
  it { is_expected.to validate_uniqueness_of(:code).case_insensitive }
  it { is_expected.to validate_presence_of :status }
  it { is_expected.to define_enum_for(:status).with_values({ active: 1, inactive: 2 }) }
  it { is_expected.to validate_presence_of :discount_value }
  it { is_expected.to validate_numericality_of(:discount_value).is_greater_than(0) }
  it { is_expected.to validate_presence_of :max_use }
  it { is_expected.to validate_numericality_of(:max_use).only_integer.is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_presence_of :due_date }

  it "can't have past due_date" do
    subject.due_date = 1.day.ago
    subject.valid?
    expect(subject.errors.keys).to include :due_date
  end

  it "is invalid with current due_date" do
    subject.due_date = Time.zone.now
    subject.valid?
    expect(subject.errors.keys).to include :due_date
  end

  it "is valid with future date" do
    subject.due_date = Time.zone.now + 1.hour
    subject.valid?
    expect(subject.errors.keys).to_not include :due_date
  end

  it_behaves_like "name searchable concern", :coupon
  it_behaves_like "paginatable concern", :coupon
end
