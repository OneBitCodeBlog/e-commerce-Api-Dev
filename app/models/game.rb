class Game < ApplicationRecord
  validates :mode, presence: true
  validates :release_date, presence: true
  validates :developer, presence: true

  belongs_to :system_requirement
  has_one :product, as: :productable

  enum mode: %i(pvp pve both)
end
