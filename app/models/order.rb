class Order < ApplicationRecord
  DAYS_TO_DUE = 7

  belongs_to :user
  belongs_to :coupon, optional: true
  has_many :line_items

  validates :status, presence: true, on: :update
  validates :subtotal, presence: true, numericality: { greater_than: 0 }
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :payment_type, presence: true
  validates :installments, presence: true, numericality: { only_integer: true, greater_than: 0 }

  enum status: { processing_order: 1, processing_error: 2, waiting_payment: 3,
                 payment_accepted: 4, payment_denied: 5, finished: 6 }

  enum payment_type: { credit_card: 1, billet: 2 }

  before_validation :set_default_status, on: :create

  def due_date
    self.created_at + DAYS_TO_DUE.days
  end

  private

  def set_default_status
    self.status = :processing_order
  end
end
