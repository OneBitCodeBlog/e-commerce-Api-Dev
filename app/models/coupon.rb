class Coupon < ApplicationRecord
  class InvalidUse < StandardError; end

  include LikeSearchable
  include Paginatable
  
  validates :name, presence: true
  validates :code, presence: true, uniqueness: { case_sensitive: false }
  validates :status, presence: true
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :due_date, presence: true, future_date: true

  enum status: { active:1,  inactive: 2 }

  def validate_use!
    raise InvalidUse unless self.active? && self.due_date >= Time.now
    true
  end
end
