require 'rails_helper'

RSpec.describe Juno::CreditCardPayment, type: :model do
  it { is_expected.to belong_to :charge }

  it { is_expected.to validate_presence_of :key }
  it { is_expected.to validate_presence_of :release_date }
  it { is_expected.to validate_presence_of :status }
end