json.categories do
  json.array! @loading_service.records, :id, :name
end