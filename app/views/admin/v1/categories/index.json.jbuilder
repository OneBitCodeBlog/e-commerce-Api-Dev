json.categories do
  json.array! @loading_service.records, :id, :name
end

json.meta do
  json.partial! 'shared/pagination', page: @loading_service.page,
                                     length: @loading_service.length,
                                     total_pages: @loading_service.total_pages
end