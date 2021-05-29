json.top_five_products do
  json.array! @service.records do |record|
    json.product record[:product]
    json.image record[:image]
    json.quantity record[:quantity]
    json.total_sold record[:total_sold].to_f
  end
end