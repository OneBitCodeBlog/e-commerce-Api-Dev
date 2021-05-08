class Game < ApplicationRecord
  include LikeSearchable
  
  belongs_to :system_requirement
  has_one :product, as: :productable
  has_many :licenses

  validates :mode, presence: true
  validates :release_date, presence: true
  validates :developer, presence: true

  enum mode: { pvp: 1, pve: 2, both: 3 }
end
