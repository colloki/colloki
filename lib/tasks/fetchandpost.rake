desc "Automatically post stories to Colloki from the cached rss stories"

task :fetchandpost => :environment do
  include ParseAndPost
  require "net/http"
  require "csv"

  begin
    #todo: put this into a config file somewhere
    source = "http://click.cs.vt.edu/colloki_data_mining/"

    #get the data for today
    today = Date.today
    d = today.strftime("%d")
    mon = Date::MONTHNAMES[Integer(today.strftime("%m"))].to(2)
    y = today.strftime("%y")
    date = d + mon + y

    #get the topics for today
    topics_file_path = source + date + "/TopicsTerms.csv"
    topics_csv = Net::HTTP.get_response(URI.parse(topics_file_path)).body

    is_first_row = true
    topics = []
    CSV.parse(topics_csv) do |row|
      # skip the first row
      if !is_first_row
        iteration_count = 0
        words = []
        row.each do |term|
          term = term.to_s.strip
          if term != ""
            # every even term is a word, odd is distribution for the word
            if iteration_count % 2 == 0
              words.push(Hash.new)
              words[words.length - 1]["name"] = term;
            else
              words[words.length - 1]["distribution"] = term;
            end
          end
          iteration_count = iteration_count + 1
        end
        topics.push(words)
      else
        is_first_row = false
      end
    end

    #stories will be added to these topics
    savedTopics = []

    #save the topics alongwith their words
    topics.each do |words|
      keyword_string = ""
      i = 0
      words_length = words.length
      words.each do |word|
        keyword_string << word["name"]
        if i != words_length - 1
          keyword_string << ", "
        end
        i += 1
      end
      # todo: Produce only 10 topics everyday (replace any existing topics produced earlier in the day)
      # The current model of topic modeling makes it unlikely that any two topics from different days will be similar
      newTopic = Topic.find(:first, :conditions => {:keywords => keyword_string})
      if !newTopic
        newTopic = Topic.new

        # todo: Come up with a better way to label topics. This is a temporary plug
        newTopic.title = words[0]["name"] + " + " + words[1]["name"]
        newTopic.keywords = keyword_string
        newTopic.save

        # save the words for each topic
        # todo: reuse words
        # todo: Produce only 10*20 keywords everyday. Replace any existing keywords for the day
        words.each do |word|
          topic_keyword = TopicKeyword.new
          topic_keyword.topic = newTopic
          topic_keyword.name = word["name"]
          topic_keyword.distribution = word["distribution"]
          topic_keyword.save
        end
      end
      savedTopics.push(newTopic);
    end

    #get the story topic distribution
    stories_topics_file_path = source + date + "/DocumentTopicsDist.csv"
    stories_topics_csv = Net::HTTP.get_response(URI.parse(stories_topics_file_path)).body
    #this will contain the topic index (in savedTopics) for each story
    stories_topics = Hash.new
    is_first_row = true
    CSV.parse(stories_topics_csv) do |row|
      # skip first row
      if !is_first_row
        i = 0
        story_id = nil
        topic_index = 0
        max_distribution = 0
        row.each do |term|
          # the first term is the story id
          if i == 0
            story_id = term
          # rest of the terms are the story's distribution in different topics
          else
            if term.to_f > max_distribution
              topic_index = i - 1
              max_distribution = term.to_f
            end
          end
          i += 1
        end
        stories_topics[story_id] = topic_index
      else
        is_first_row = false
      end
    end

    #get all the stories for today and post them to colloki
    stories_file_path = source + date + "/stories.csv"
    stories_csv = Net::HTTP.get_response(URI.parse(stories_file_path)).body
    CSV.parse(stories_csv) do |row|
      if stories_topics[row[0]]
        ParseAndPost::run(row[3], savedTopics[stories_topics[row[0]]])
      else
        ParseAndPost::run(row[3], nil)
      end
    end
  rescue

  end
end