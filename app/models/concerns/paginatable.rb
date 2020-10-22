module Paginatable
  extend ActiveSupport::Concern

  MAX_PER_PAGE = 10
  DEFAULT_PAGE = 1

  included do
    scope :paginate, -> (page, length) do
      start_at = (page || DEFAULT_PAGE).to_i - 1
      length ||= MAX_PER_PAGE
      offset = start_at * length
      limit(length).offset(offset)
    end
  end
end