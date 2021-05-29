json.summary do
  json.users @service.records[:users]
  json.products @service.records[:products]
  json.orders @service.records[:orders]
  json.profit @service.records[:profit]
end