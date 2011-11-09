module ParseAndPost
  def self.run(url, topic)
    require 'nokogiri'
    require 'net/http'
    require 'open-uri'

    #check if the story already exists. if yes, return it, instead of reposting it
    story = Story.find(:first, :conditions => {:source_url => url})
    if story
      story.topic = topic
      story.save
    end

    domain = url.split('/')[2]
    doc = Nokogiri::HTML(Net::HTTP.get(URI.parse(url)))

    if StoryFetcherController::Sources.has_key?(domain)
      name = StoryFetcherController::Sources[domain]["name"]
      @title = doc.css(StoryFetcherController::Sources[domain]["title"]).first.text
      @content = doc.css(StoryFetcherController::Sources[domain]["content"]).to_html.html_safe
      @image = nil
      if StoryFetcherController::Sources[domain]["image"] != nil
        img_tags = doc.css(StoryFetcherController::Sources[domain]["image"])
        if !img_tags.empty?
          src = img_tags.first['src']
          if (src.index(StoryFetcherController::Sources[domain]["url"]))
            @image = "#{src}"
          else
            @image = "#{StoryFetcherController::Sources[domain]["url"]}#{src}"
          end
        end
      end

      # save the fetched story
      story = Story.new
      story.title = @title
      story.description = @content
      story.topic = topic
      if @image
        story.image = open(@image)
      end
      story.views = 0
      story.kind = Story::Rss
      story.source = name
      story.source_url = url
      story.save
    end
  end
end