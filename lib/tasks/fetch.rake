require 'mining_store.rb'
require 'map_coordinates.rb'
require 'facebook_autoposter.rb'
require 'open-uri'

config = YAML.load_file("#{Rails.root}/config/sources.yml")[Rails.env]
@@source_names = config['rss']
@@source_blacklist = config['rss_blacklist']

# Gets the blog stories from a "VTSTopicModeling" installation
desc "Post stories to VTS from the cached rss stories"

task :fetch, [:start_date, :end_date] => [:environment] do |t, args|
  begin
    args.with_defaults(:start_date => nil, :end_date => nil)

    if args.start_date
      start_date = Date.strptime(args.start_date, "%m/%d/%Y")
    else
      start_date = Time.now.in_time_zone('EST').to_date
    end

    if args.end_date
      end_date = Date.strptime(args.end_date, "%m/%d/%Y")
    else
      end_date = Time.now.in_time_zone('EST').to_date
    end

    start_date.upto(end_date) do |day|
      puts "========================================================"
      puts "Fetching articles for " + day.to_s + "..."

      begin
        mining_store = MiningStore.new(day)
        facebook     = FacebookAutoposter.new
      rescue
        puts "Error fetching data for the day"
        next
      end

      topics = []

      # Get rid of past topics created during the day.
      # This is highly transient right now...
      Topic.delete_all(["day = ?", day.to_time.utc])

      # Save the topics
      mining_store.topics.each do |topic|
        new_topic = Topic.new
        new_topic.title = topic["label"]
        new_topic.keywords = topic["keyword_string"]
        new_topic.day = day
        new_topic.save

        # Save the keywords for the topic. TODO: Reuse keywords
        topic["keywords"].each do |word|
          keyword = TopicKeyword.new
          keyword.topic = new_topic
          keyword.name = word["name"]
          keyword.distribution = word["distribution"]
          keyword.save
        end

        puts "Saved new topic: " + topic['keywords'].join(', ')
        topics.push(new_topic)
      end

      # Post the stories
      mining_store.stories.each do |story|
        begin
          if !@@source_blacklist[story["source"]]

            topic_index = mining_store.get_topic_index_for_story(story)
            if topic_index
              topic = topics[topic_index]
            else
              topic = nil
            end

            # check if the story already exists
            # TODO: Add more duplicate checks here
            new_story =
              Story.find(:first, :conditions => {:source_url => story["link"]})

            puts "======================================="
            puts story["link"]

            if new_story
              if topic and new_story.topic != topic
                new_story.topic = topic
                new_story.save
              end
            else
              puts "Saving new story: " + story["link"]
              new_story = Story.new
              new_story.title = story["title"].force_encoding("utf-8")
              new_story.description = story["text"].force_encoding("utf-8")

              # Story topic
              if topic
                new_story.topic = topic
              else
                new_story.topic_id = -1
              end

              # Story Image
              if story["image-url"] && story["image-url"] != ""
                # TODO: Only save image here if it was properly fetched
                new_story.image = open(URI::escape(story["image-url"]))
              end

              new_story.views = 0
              new_story.kind = Story::Rss

              if story["source-name"]
                new_story.source = story["source-name"]
              elsif @@source_names[story["source"]]
                new_story.source = @@source_names[story["source"]]
              else
                new_story.source = story["source"]
              end

              new_story.source_url = story["link"]

              if story["published-at"] and !story["published-at"].empty?
                new_story.published_at = DateTime.strptime(story["published-at"], '%Y-%m-%dT%H:%M:%S%z')
              else
                new_story.published_at = day
              end

              coordinates = MapCoordinates.find(new_story)
              if coordinates.length > 0
                new_story.latitude = coordinates[0]
                new_story.longitude = coordinates[1]
              end

              new_story.save

              puts "Successfully saved story: " + story["link"]
            end
          else
            puts story["source"] + " is BLACLISTED, so article ignored."
          end
        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
        end
      end
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
  end
end
