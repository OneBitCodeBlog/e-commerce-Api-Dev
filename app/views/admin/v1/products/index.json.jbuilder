json.products do
  json.array! @loading_service.records do |product|
    json.partial! product
    json.partial! product.productable
  end
end