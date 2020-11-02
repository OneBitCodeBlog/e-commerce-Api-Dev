module Paginatable
  extend ActiveSupport::Concern

  MAX_PER_PAGE = 10
  DEFAULT_PAGE = 1

  included do
    scope :paginate, -> (page, length) do
      page = page.present? && page > 0 ? page : DEFAULT_PAGE
      length = length.present? && length > 0 ? length : MAX_PER_PAGE
      starts_at = (page - 1) * length
      limit(length).offset(starts_at)
    end
  end
end