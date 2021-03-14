json.orders do
  json.array! @loading_service.records do |order| 
    json.(order, :id, :status, :total_amount, :payment_type)
  end
end

json.meta do
  json.partial! 'shared/pagination', pagination: @loading_service.pagination
end