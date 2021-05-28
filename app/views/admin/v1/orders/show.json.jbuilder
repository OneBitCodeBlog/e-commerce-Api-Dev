json.order do
  json.(@order, :id, :status, :total_amount, :subtotal, :payment_type)
  json.discount @order.coupon&.discount_value&.to_f
  json.line_items @order.line_items do |line_item| 
    json.(line_item, :quantity, :payed_price)
    json.product line_item.product.name
  end
end