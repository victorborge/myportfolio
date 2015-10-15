json.array!(@sponsors) do |sponsor|
  json.extract! sponsor, :id, :name
  json.url sponsor_url(:admin, sponsor, format: :json)
end
