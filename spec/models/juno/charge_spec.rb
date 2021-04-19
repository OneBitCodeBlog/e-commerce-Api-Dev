require 'rails_helper'

RSpec.describe Juno::Charge, type: :model do
  subject { build(:juno_charge) }

  it { is_expected.to belong_to :order }  
  it { is_expected.to have_many :credit_card_payments }

  it { is_expected.to validate_presence_of :key }
  it { is_expected.to validate_presence_of :code }
  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_uniqueness_of(:number).scoped_to(:order_id).case_insensitive }
  it { is_expected.to validate_numericality_of(:number).is_greater_than(0).only_integer }
  it { is_expected.to validate_presence_of(:amount) }
  it { is_expected.to validate_numericality_of(:amount).is_greater_than(0) }
  it { is_expected.to validate_presence_of :status }
end