module LikeSearchable
  extend ActiveSupport::Concern

  included do
    scope :like, -> (key, value) do
      like_statement = self.arel_table[key].matches("%#{value}%")
      self.where(like_statement)
    end
  end
end