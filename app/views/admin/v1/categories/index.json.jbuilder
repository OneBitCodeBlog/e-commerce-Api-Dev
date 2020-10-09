json.categories do
  json.array! @categories, :id, :name
end