
require "colloki_mining_store.rb"
require "facebook_autoposter.rb"
require "open-uri"

@@source_names = Hash[
  "www.collegiatetimes.com"             => "Collegiate Times",
  "blogs.roanoke.com"                   => "The Burgs Blog",
  "www.roanoke.com"                     => "The Roanoke Times",
  "www.vtnews.vt.edu"                   => "Virginia Tech News",
  "www.bev.net"                         => "Blacksburg Electronic Village",
  "www.citizensfirstforblacksburg.org"  => "Citizens First For Blacksburg",
  "www.christiansburg.org"              => "Christiansburg Virginia",
  "downtownblacksburg.wordpress.com"    => "Downtown Blacksburg Blog",
  "www.myvaresources.com"               => "Depotdazed",
  "nrvnews.com"                         => "NRV News",
  "www2.swvatoday.com"                  => "SWVA Today",
  "www.southwesttimes.com"              => "The Southwest Times",
  "www.lwvmcva.org"                     => "League of Women Voters in Montgomery County",
  "www.blacksburg.va.us"                => "Town of Blacksburg",
  "swvanews.com"                        => "Southwest Virginia Blogs"
]

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
        mining_store = CollokiMiningStore.new(day)
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

      # Post the stories to Colloki
      mining_store.stories.each do |story|
        begin
          topic_index = mining_store.get_topic_index_for_story(story)
          if topic_index
            topic = topics[topic_index]
          else
            topic = nil
          end

          # check if the story already exists
          new_story = Story.find(:first, :conditions => {:source_url => story["link"]})

          if new_story
            if topic and new_story.topic != topic
              new_story.topic = topic
              new_story.save
            end
          else
            puts "Saving new story: " + story["link"]
            new_story = Story.new
            new_story.title = story["title"]
            new_story.description = story["text"]
            if topic
              new_story.topic = topic
            else
              new_story.topic_id = -1
            end
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
            new_story.save

            # Post story to Facebook page
            # if facebook and new_story
            #   facebook.post(new_story)
            # end

            puts "Successfully saved story: " + story["link"]
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