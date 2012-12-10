require 'map_coordinates.rb'

desc "Fetch and add location coordinates to RSS stories"
task :maps => :environment do |t, args|
  begin
    stories = Story.find(:all, :conditions => ["kind != 4"], :order=>"created_at DESC")
    for story in stories
      if story.latitude == nil
        coordinates = MapCoordinates.find(story)
        if coordinates.length > 0
          story.latitude = coordinates[0]
          story.longitude = coordinates[1]
          story.save
        end
      end
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
  end
end
