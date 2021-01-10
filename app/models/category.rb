class Category < ApplicationRecord
  include LikeSearchable
  include Paginatable

  has_many :product_categories, dependent: :destroy
  has_many :products, through: :product_categories
  
  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
