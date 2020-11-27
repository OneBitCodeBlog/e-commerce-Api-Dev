json.system_requirements do
  json.array! @loading_service.records, 
              :id, :name, :operational_system, :storage, :processor, :memory, :video_board
end

json.meta do
  json.partial! 'shared/pagination', page: @loading_service.page,
                                     length: @loading_service.length,
                                     total_pages: @loading_service.total_pages
end