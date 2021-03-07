class Juno::CreditCardPayment < ApplicationRecord
  belongs_to :charge

  validates :key, presence: true
  validates :release_date, presence: true
  validates :status, presence: true
end
