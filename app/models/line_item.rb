class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :payed_price, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, on: :update

  enum status: { waiting_order: 1, preparing: 2, en_route: 3, delivered: 4 }

  before_validation :set_default_status, on: :create

  def total
    self.payed_price * self.quantity
  end

  private

  def set_default_status
    self.status = :waiting_order
  end
end