json.array!(@items) do |item|
  json.extract! item, :id, :name, :description, :amount, :ratio_1, :ratio_2, :ratio_3, :ratio_4, :ratio_5
  json.url item_url(item, format: :json)
end
