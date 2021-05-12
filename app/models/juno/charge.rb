class Juno::Charge < ApplicationRecord
  belongs_to :order
  has_many :credit_card_payments, class_name: "Juno::CreditCardPayment"
  
  validates :key, presence: true
  validates :code, presence: true
  validates :number, presence: true,
                     uniqueness: { scope: :order_id },
                     numericality: { only_integer: true, greater_than: 0 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true
end