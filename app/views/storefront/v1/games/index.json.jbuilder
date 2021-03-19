json.games do
  json.array! @games do |game|
    json.(game.product, :id, :name, :description)
    json.image_url rails_blob_url(game.product.image)
    json.partial! game
    json.licenses game.product.line_items.map(&:licenses).flatten.map(&:key)
  end
end