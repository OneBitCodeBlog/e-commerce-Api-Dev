json.system_requirements do
  json.array! @system_requirements, :id, :name, :operational_system, :storage, :processor, :memory, :video_board
end