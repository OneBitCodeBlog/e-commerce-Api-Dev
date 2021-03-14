json.orders do
  json.array! @orders do |order| 
    json.(order, :id, :status, :total_amount, :payment_type)
  end
end