require 'rails_helper'

RSpec.describe Product, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_presence_of(:price) }
  it { is_expected.to validate_numericality_of(:price) }

  it { is_expected.to belong_to :productable }
  it { is_expected.to have_many :product_categories }
  it { is_expected.to have_many(:categories).through(:product_categories) }
end
