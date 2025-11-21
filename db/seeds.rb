# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

require "json"
require "uri"
require "net/http"

puts "Nettoyage de la base de données..."
Movie.destroy_all

puts "Récupération des films depuis l'API TMDB..."

url = URI("https://api.themoviedb.org/3/movie/top_rated?language=en-US&page=1")

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true

request = Net::HTTP::Get.new(url)
request["accept"] = "application/json"
request["Authorization"] = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJiYjc1YjNlYzFjYWU2ZTI4ZTE2ZDNhZjUyZjViOWMxNiIsIm5iZiI6MTc2MzcyMjI1OC4zMDU5OTk4LCJzdWIiOiI2OTIwNDQxMjE5NzQ1YzNmNzk1ZDYxYzAiLCJzY29wZXMiOlsiYXBpX3JlYWQiXSwidmVyc2lvbiI6MX0.AJ70iU-PQijGis4Jpzh9AsEtEnTaejq2clB3M8tbJyQ"

response = http.request(request)
data = JSON.parse(response.read_body)

if data["results"]
  data["results"].each do |movie_data|
    Movie.create!(
      title: movie_data["title"],
      overview: movie_data["overview"],
      poster_url: "https://image.tmdb.org/t/p/w500#{movie_data["poster_path"]}",
      rating: movie_data["vote_average"]
    )
    puts "Créé: #{movie_data["title"]}"
  end
  puts "#{Movie.count} films créés avec succès !"
else
  puts "Erreur lors de la récupération des films"
  puts response.read_body
end
