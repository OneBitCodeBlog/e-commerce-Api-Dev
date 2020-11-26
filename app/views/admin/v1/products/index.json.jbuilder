json.products do
  json.array! @loading_service.records do |product|
    json.partial! product
    json.partial! product.productable
  end
end

json.meta do
  json.partial! 'shared/pagination', page: @loading_service.page,
                                     length: @loading_service.length,
                                     total_pages: @loading_service.total_pages
end