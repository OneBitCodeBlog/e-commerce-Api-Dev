module Storefront
  class HomeLoaderService
    QUANTITY_OF_RECORDS_PER_GROUP = 4
    MIN_RELEASE_DAYS = 7

    attr_reader :featured, :last_releases, :cheapest

    def initialize
      @featured = []
      @recently_releases = []
      @cheapest = []
    end

    def call
      games = Product.joins("JOIN games ON productable_type = 'Game' AND productable_id = games.id")
                     .includes(productable: [:game]).where(status: :available)
      @featured = load_featured_games(games)
      @last_releases = load_last_released_games(games)
      @cheapest = load_cheapest_games(games)
    end

    private

    def load_featured_games(games)
      games.where(featured: true).sample(QUANTITY_OF_RECORDS_PER_GROUP)
    end

    def load_last_released_games(games)
      games.where(games: { release_date: MIN_RELEASE_DAYS.days.ago.beginning_of_day..Time.now.end_of_day })
           .sample(QUANTITY_OF_RECORDS_PER_GROUP)
    end

    def load_cheapest_games(games)
      games.order(price: :asc).take(QUANTITY_OF_RECORDS_PER_GROUP)
    end
  end
end