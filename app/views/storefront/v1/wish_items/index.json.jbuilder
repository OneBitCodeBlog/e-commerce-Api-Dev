json.wish_items do
  json.array! @wish_items do |wish_item|
    json.partial! wish_item
  end
end