json.system_requirements do
  json.array! @loading_service.records, 
              :id, :name, :operational_system, :storage, :processor, :memory, :video_board
end

json.meta do
  json.partial! 'shared/pagination', pagination: @loading_service.pagination
end