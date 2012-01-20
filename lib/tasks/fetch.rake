require "colloki_mining_store.rb"
require "open-uri"

desc "Automatically post stories to Colloki from the cached rss stories"
task :fetch => :environment do
  begin
    # Initialize the mining store for today
    mining_store = CollokiMiningStore.new(Date.today)
    topics = []

    # Save the topics
    mining_store.topics.each do |topic|
      # Check if the topic already exists
      new_topic = Topic.find(:first, :conditions => {:keywords => topic["keyword_string"]})
      # If it doesn't, create a new topic
      if !new_topic
        new_topic = Topic.new
        new_topic.title = topic["label"]
        new_topic.keywords = topic["keyword_string"]
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
      end
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
          new_story = Story.new
          new_story.title = story["title"]
          new_story.description = story["text"]
          if topic
            new_story.topic = topic
          else
            new_story.topic_id = -1
          end
          if story["image-url"] && story["image-url"] != ""
            new_story.image = open(URI::escape(story["image-url"]))
          end
          new_story.views = 0
          new_story.kind = Story::Rss
          new_story.source = story["source"] # todo: Needs to be source name
          new_story.source_url = story["link"]
          # puts "Topic: " + topic
          new_story.topic = topic
          new_story.save
          puts "Successfully saved story: " + story["link"]
        end
      rescue Exception => e
        puts e.message
        puts e.backtrace.inspect
      end
    end

  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
  end
end