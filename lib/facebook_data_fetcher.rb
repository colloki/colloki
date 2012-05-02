
require 'open-uri'
require 'uri'
require 'json'

# Fetches facebook stories from a "rss_cacher" installation
class FacebookDataFetcher

  CONFIG    = YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]
  @@source  = CONFIG['fb_datasource']

  def initialize
    @stories = get_stories(format_date(Time.now.to_date))
  end

  def stories
    return @stories
  end

  def format_date(date)
    return date.strftime("%Y-%m-%d")
  end

  def get_stories(date)
    @stories = []
    path = @@source + "cache/" + date + ".json"
    puts "Fetching Facebook stories for " + date + "..."
    content = open(path).read
    json    = JSON.parse(content)
    json.each do |item|
      @stories.push item["story"]
    end
    return @stories
  end
end
