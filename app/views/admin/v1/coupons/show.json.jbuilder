json.coupon do
  json.(@coupon, :id, :name, :code, :status, :discount_value, :due_date)
end