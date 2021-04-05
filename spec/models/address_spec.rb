require 'rails_helper'

RSpec.describe Address, type: :model do
  it { is_expected.to validate_presence_of(:street) }
  it { is_expected.to validate_presence_of(:number) }
  it { is_expected.to validate_presence_of(:city) }
  it { is_expected.to validate_presence_of(:state) }
  it { is_expected.to validate_presence_of(:post_code) }
end