module Storefront::V1
  class GamesController < ApiController
    def index
      @games = Game.includes(product: { line_items: [:order, :licenses] })
                   .where(orders: { user_id: current_user })
                   .select("products.*, games.*, licenses.key")
    end
  end
end