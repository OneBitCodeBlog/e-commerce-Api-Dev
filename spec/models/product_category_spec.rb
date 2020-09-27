require 'rails_helper'

RSpec.describe ProductCategory, type: :model do
  it { is_expected.to belong_to :product }
  it { is_expected.to belong_to :category }
end
