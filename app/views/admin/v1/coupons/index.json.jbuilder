json.coupons do
  json.array! @loading_service.records, :id, :name, :code, :status, :discount_value, :due_date
end

json.meta do
  json.partial! 'shared/pagination', page: @loading_service.page,
                                     length: @loading_service.length,
                                     total_pages: @loading_service.total_pages
end