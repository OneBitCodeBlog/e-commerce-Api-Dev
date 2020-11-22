class Coupon < ApplicationRecord
  include NameSearchable
  include Paginatable
  
  validates :name, presence: true
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :status, presence: true
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :due_date, presence: true, future_date: true

  enum status: { active:1,  inactive: 2 }
end
