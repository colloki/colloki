class StoryFetcherController < ApplicationController
  # Fetches a page's HTML and then parses it to get story title, content and any images. Then saves the story.
  def parse
    require 'nokogiri'
    require 'net/http'
    require 'open-uri'
    url = params[:url]
    doc = Nokogiri::HTML(Net::HTTP.get(URI.parse(url)))

    # todo: come up with an independent, extendible way to plug-in modules for different sites
    # todo: This is a *very* flaky idea, it works on the assumption that these sites don't have any major design changes. If they do, these modules need to be updated asap

    # Collegiate Times
    if url.include? "collegiatetimes.com"
      source = "Collegiate Times"
      @title = doc.css("p.headline").first.text
      @content = doc.css("#story>p").to_html.html_safe
      image_tags = doc.css(".img img")
      if !image_tags.empty?
        @image = "http://www.collegiatetimes.com#{image_tags.first['src']}"
      end

    # The Burgs Blog
    # todo: currently, this has to be above "The Roanoke Times", because it is a subpart of it. Get rid of this dependency
    elsif url.include? "blogs.roanoke.com/theburgs"
      source = "The Burgs Blog"
      @title = doc.css("#post>h1").first.text
      @content = doc.css("#post>p").to_html.html_safe
      # todo: images

    # The Roanoke Times
    elsif url.include? "roanoke.com"
      source = "The Roanoke Times"
      @title = doc.css("#main h1").first.text
      @content = doc.css("#story-text>p").to_html.html_safe
      # todo: images

    # Virginia Tech News
    elsif url.include? "vtnews.vt.edu"
      source = "Virginia Tech News"
      @title = doc.css("h2.vt_pr_storytitle").first.text
      @content = doc.css("#vt_pr_content_body>p").to_html.html_safe
      image_tags = doc.css("#vt_pr_storyimage img")
      if !image_tags.empty?
        @image = "http://vtnews.vt.edu#{image_tags.first['src']}"
      end

    # Blacksburg Electronic Village (bev.net)
    elsif url.include? "bev.net"
      source = "Blacksburg Electronic Village"
      @title = doc.css(".listingTitle").first.text
      @content = doc.css(".field-items p").to_html.html_safe
      # todo: prepend table containing event schedule to content
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