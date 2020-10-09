json.errors do
  json.fields fields if defined?(fields) && fields.present?
  json.message message if defined?(message) && message.present?
end