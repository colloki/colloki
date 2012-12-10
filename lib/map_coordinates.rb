require 'net/http'
require 'uri'
require 'json'

class MapCoordinates
  def self.find(story)
    x = Net::HTTP.post_form(
      URI.parse('http://addressextract.appspot.com/extract/'),
      {'content' => story.description})

    puts x.body
    json = JSON.parse x.body

    for address in json['addresses']
      coordinates = Geocoder.coordinates(address[0])
      if coordinates and coordinates.length > 0
        puts coordinates
        return coordinates
      end
    end

    return []
  end
end
