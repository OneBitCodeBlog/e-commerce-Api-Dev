class Address
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :street
  attribute :number
  attribute :city
  attribute :state
  attribute :post_code

  validates :street, presence: true
  validates :number, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :post_code, presence: true
end