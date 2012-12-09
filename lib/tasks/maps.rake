require 'net/http'
require 'uri'
require 'json'

desc "Fetch and add location coordinates to RSS stories"
task :maps => :environment do |t, args|
  begin
    stories = Story.find(:all, :conditions => {:kind => 2}, :limit => 1000)
    for story in stories
      if story.latitude == nil
        params = {'content' => story.description}
        x = Net::HTTP.post_form(URI.parse('http://addressextract.appspot.com/extract/'), params)
        puts x.body
        json = JSON.parse x.body
        for address in json['addresses']
          coordinates = Geocoder.coordinates(address[0])
          if coordinates and coordinates.length > 0
            puts address[0]
            puts coordinates
            story.latitude = coordinates[0]
            story.longitude = coordinates[1]
            story.save
            break
          end
        end
      end
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
  end
end
