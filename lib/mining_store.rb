require "net/http"
require "csv"
require "cgi"

# Gets the data from the Topic Modeling Data Source.
class MiningStore

  CONFIG = YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]

  # Class config variables
  @@source = CONFIG['TM_url']
  @@topics_path = CONFIG['TM_topics_path']
  @@document_topic_distribution_path = CONFIG['TM_document_topic_path']
  @@stories_path = CONFIG['TM_stories_path']

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

  def formatted_date
    return @formatted_date
  end

  def get_topic_index_for_story(story)
    return @distribution[story["id"]]
  end

  private

    def format_date(date)
      day = date.strftime("%d")
      month = Date::MONTHNAMES[date.strftime("%m").to_i()].to(2)
      year = date.strftime("%y")
      return day + month + year
    end

    # As a temporary placeholder, we create a label out of the top two words
    def get_label(keywords)
      if keywords and !keywords.empty?
        return keywords[0]["name"] + " + " + keywords[1]["name"]
      else
        return nil
      end
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
                keyword["name"] = term.strip
                keywords.push(keyword)
              # Odd term is the previous word's distribution
              else
                keywords[keywords.length - 1]["distribution"] = term.strip
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
          distribution[story_id.strip] = topic_index
        else
          is_first_row = false
        end
      end
      return distribution
    end

    def get_stories
      path = @@source + @formatted_date + "/" + @@stories_path
      csv = CGI::escapeHTML(Net::HTTP.get_response(URI.parse(path)).body)
      stories = []
      header = []
      is_first_row = true
      CSV.parse(csv) do |row|
        if is_first_row
          header = row
          is_first_row = false
        else
          story = Hash.new
          header.each_with_index do |field, i|
            story[field.strip] = (CGI::unescapeHTML(row[i])).strip
          end
          stories.push(story)
        end
      end
      return stories
    end
end
