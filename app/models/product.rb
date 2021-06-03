class Product < ApplicationRecord
  include LikeSearchable
  include Paginatable
  
  belongs_to :productable, polymorphic: true
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories
  has_many :wish_items
  has_many :line_items

  has_one_attached :image

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :image, presence: true
  validates :status, presence: true
  validates :featured, presence: true, if: -> { featured.nil? }

  enum status: { available: 1, unavailable: 2 }

  def sells_count
    self.line_items.joins(:order).where(orders: { status: :finished }).sum(:quantity)
  end
end
