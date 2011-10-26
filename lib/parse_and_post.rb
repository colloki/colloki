module ParseAndPost
  def run(url)
    require 'nokogiri'
    require 'net/http'
    require 'open-uri'

    domain = url.split('/')[2]
    doc = Nokogiri::HTML(Net::HTTP.get(URI.parse(url)))

    if StoryFetcherController::Sources[domain]
      Rails.logger.info("#{url}");
      name = StoryFetcherController::Sources[domain]["name"]
      @title = doc.css(StoryFetcherController::Sources[domain]["title"]).first.text
      @content = doc.css(StoryFetcherController::Sources[domain]["content"]).to_html.html_safe
      @image = nil
      if StoryFetcherController::Sources[domain]["image"] != nil
        img_tags = doc.css(StoryFetcherController::Sources[domain]["image"])
        if !img_tags.empty?
          @image = "#{StoryFetcherController::Sources[domain]["url"]}#{img_tags.first['src']}"
        end
      end
      # save the fetched story
      story = Story.new
      story.title = @title
      story.description = @content
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