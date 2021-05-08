class License < ApplicationRecord
  include Paginatable
  include LikeSearchable
  
  belongs_to :game
  belongs_to :line_item, optional: true

  validates :key, presence: true, uniqueness: { case_sensitive: false, scope: :platform }
  validates :platform, presence: true
  validates :status, presence: true
  validates :line_item, presence: true, if: -> { self.status == 'in_use' }

  enum platform: { steam: 1, battle_net: 2, origin: 3 } 
  enum status: { available: 1, in_use: 2, inactive: 3 }
end
