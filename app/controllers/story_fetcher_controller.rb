class StoryFetcherController < ApplicationController
  # Fetches a page's HTML and then parses it to get story title, content and any images. Then saves the story.
  def parse
    require 'nokogiri'
    require 'net/http'
    require 'open-uri'
    url = params[:url]
    doc = Nokogiri::HTML(Net::HTTP.get(URI.parse(url)))

    # todo: come up with an independent way to plug in modules for different sites
    # we are assuming since it is a small town, we are going to have a limited no. of sources.
    if url.include? "collegiatetimes.com"
      source = "CollegiateTimes"
      @title = doc.css('p.headline').first.text
      @content = doc.css('#story>p').to_html.html_safe
      image_tags = doc.css('.img img')
      if !image_tags.empty?
        @image = "http://www.collegiatetimes.com#{image_tags.first['src']}"
      end
    elsif url.include? "roanoke.com"
      source = "The Roanoke Times"
      @title = doc.css('#main h1').first.text
      @content = doc.css('#story-text>p').to_html.html_safe
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
    story.source = source
    story.source_url = url
    story.save
  end

  def index
  end
end
