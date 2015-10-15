json.array!(@events) do |event|
  json.extract! event, :title, :content, :starts_at, :ends_at
  json.url event_url(event, format: :json)
end