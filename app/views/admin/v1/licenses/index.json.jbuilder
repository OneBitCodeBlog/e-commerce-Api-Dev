json.licenses do
  json.array! @loading_service.records, :id, :key, :platform, :status, :game_id
end

json.meta do
  json.partial! 'shared/pagination', pagination: @loading_service.pagination
end