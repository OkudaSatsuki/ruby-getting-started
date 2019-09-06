json.extract! datum, :id, :name, :first, :third, :fifth, :created_at, :updated_at, :url
json.url datum_url(datum, format: :json)
