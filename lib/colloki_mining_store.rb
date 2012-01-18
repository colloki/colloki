require "net/http"
require "csv"

class CollokiMiningStore

  # Class config variables
  @@source                            = "http://click.cs.vt.edu/colloki_data_mining/"
  @@topics_path                       = "TopicsTerms.csv"
  @@document_topic_distribution_path  = "DocumentTopicsDist.csv"
  @@stories_path                      = "stories.csv"

  def initialize(date)
    @formatted_date = format_date(date)
    @topics = get_topics
    @distribution = get_story_topic_distribution
    @stories = get_stories
  end

  def topics
    return @topics
  end

  def stories
    return @stories
  end

  def story_has_topic(story)
    return @distribution[story["id"]]
  end


  private

  def format_date(date)
    day = date.strftime("%d")
    month = Date::MONTHNAMES[Integer(date.strftime("%m"))].to(2)
    year = date.strftime("%y")
    return day + month + year
  end

  # As a temporary placeholder, we create a label out of the top two words
  def get_label(keywords)
    return keywords[0]["name"] + " + " + keywords[1]["name"]
  end

  # Keyword strings are of the form 'word1, word2, ...'
  def get_keyword_string(keywords)
    length = keywords.length    
    keyword_string = ""
    i = 0
    keywords.each do |keyword|
      keyword_string << keyword["name"] 
      if i != length - 1
        keyword_string << ", "
      end
      i += 1
    end
    return keyword_string
  end

  def get_topics
    path = @@source + @formatted_date + "/" + @@topics_path
    csv = Net::HTTP.get_response(URI.parse(path)).body
    topics = []

    first_row = true
    CSV.parse(csv) do |topic|
      if !first_row
        count = 0
        keywords = []
        topic.each do |term|
          term = term.to_s.strip
          if term != ""
            # Even term is the word
            if count % 2 == 0
              keyword = Hash.new
              keyword["name"] = term
              keywords.push(keyword)
            # Odd term is the previous word's distribution
            else
              keywords[keywords.length - 1]["distribution"] = term
            end
          end
          count = count + 1
        end

        topic = Hash.new
        topic["keywords"] = keywords
        topic["label"] = get_label(keywords)
        topic["keyword_string"] = get_keyword_string(keywords)
        topics.push(topic)
      else
        first_row = false
      end
    end
    return topics
  end

  def get_story_topic_distribution
    path = @@source + @formatted_date + "/" + @@document_topic_distribution_path
    csv = Net::HTTP.get_response(URI.parse(path)).body
    
    # Assign a topic for each story
    # Story id is the key and key value is the topic index
    distribution = Hash.new
    
    is_first_row = true
    CSV.parse(csv) do |row|
      # Skip first row which is the header
      if !is_first_row
        i = 0
        story_id = nil
        topic_index = 0
        max_distribution = 0
        row.each do |term|
          # The first term is the story id
          if i == 0
            story_id = term
          # Rest of the terms are the story's distribution in different topics
          else
            if term.to_f > max_distribution
              topic_index = i - 1
              max_distribution = term.to_f
            end
          end
          i += 1
        end
        distribution[story_id] = topic_index
      else
        is_first_row = false
      end
    end
    return distribution
  end

  def get_stories
    path = @@source + @formatted_date + "/" + @@stories_path
    csv = Net::HTTP.get_response(URI.parse(path)).body
    stories = []
    CSV.parse(csv) do |row|
      story = Hash.new
      story["id"] = row[0].to_i
      story["url"] = row[3]
      stories.push(story)
    end
    return stories
  end
end