class Product < ApplicationRecord
  include NameSearchable
  include Paginatable
  
  has_one_attached :image

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :description, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :image, presence: true
  validates :status, presence: true
  
  belongs_to :productable, polymorphic: true
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories

  enum status: { available: 1, unavailable: 2 }
end
