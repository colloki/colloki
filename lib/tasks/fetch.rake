require "colloki_mining_store.rb"

desc "Automatically post stories to Colloki from the cached rss stories"
task :fetchandpost => :environment do
  include ParseAndPost

  begin
    # Initialize the mining store for today
    mining_store = CollokiMiningStore.new(Date.today)
    topics = []

    # Save the topics
    mining_store.topics.each do |topic|
      # Check if the topic already exists
      a_topic = Topic.find(:first, :conditions => {:keywords => topic["keyword_string"]})

      # If it doesn't, create a new topic
      if !a_topic
        a_topic = Topic.new
        a_topic.title = topic["label"]
        a_topic.keywords = topic["keyword_string"]
        a_topic.save

        # Save the keywords for the topic. TODO: Reuse keywords
        topic["keywords"].each do |word|
          keyword = TopicKeyword.new
          keyword.topic = a_topic
          keyword.name = word["name"]
          keyword.distribution = word["distribution"]
          keyword.save
        end
      end
      topics.push(a_topic)
    end

    # Post the stories to Colloki
    mining_store.stories.each do |story|
      if mining_store.story_has_topic(story)
        ParseAndPost::run(story["url"], topics[story["id"]])
      else
        ParseAndPost::run(story["url"], nil)
      end
    end

  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect     
  end
end