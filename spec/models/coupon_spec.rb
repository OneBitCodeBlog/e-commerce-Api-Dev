require 'rails_helper'

RSpec.describe Coupon, type: :model do
  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :code }
  it { is_expected.to validate_uniqueness_of(:code).case_insensitive }
  it { is_expected.to validate_presence_of :status }
  it { is_expected.to define_enum_for(:status).with_values({ active: 1, inactive: 2 }) }
  it { is_expected.to validate_presence_of :discount_value }
  it { is_expected.to validate_numericality_of(:discount_value).is_greater_than(0) }
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

  context "on #validate_use!" do
    subject { build(:coupon) }
     
    it "raise InvalidUse when it's overdue" do
      subject.due_date = 2.days.ago
      expect do
        subject.validate_use!
      end.to raise_error(Coupon::InvalidUse)
    end

    it "raise InvalidUse when it's inactive" do
      subject.status = :inactive
      expect do
        subject.validate_use!
      end.to raise_error(Coupon::InvalidUse)
    end

    it "returns true when it's on date and active" do
      expect(subject.validate_use!).to eq true
    end
  end

  it_has_behavior_of "like searchable concern", :coupon, :name
  it_behaves_like "paginatable concern", :coupon
end