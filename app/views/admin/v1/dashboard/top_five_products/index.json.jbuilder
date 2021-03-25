json.top_five_products do
  json.array! @service.records do |record|
    json.product record[:product]
    json.quantity record[:quantity]
    json.total_sold record[:total_sold]
  end
end