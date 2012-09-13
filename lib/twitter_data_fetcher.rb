require 'open-uri'
require 'uri'
require 'json'

# Fetches tweets from a "rss_cacher" installation
# TODO: Combine this with FacebookDataFetcher. They are almost the same.
class TwitterDataFetcher
  CONFIG = YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]
  @@source = CONFIG['twitter_datasource']

  def initialize(date)
    @stories = get_stories(format_date(date))
  end

  def stories
    return @stories
  end

  def format_date(date)
    return date.strftime("%Y-%m-%d")
  end

  def get_stories(date)
    puts date
    @stories = []
    path = @@source + "cache/" + date + ".json"
    puts "Fetching Twitter stories for " + date + "..."
    content = open(path).read
    json = JSON.parse(content)
    json.each do |item|
      @stories.push item["story"]
    end
    return @stories
  end
end
