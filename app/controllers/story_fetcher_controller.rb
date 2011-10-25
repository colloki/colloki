class StoryFetcherController < ApplicationController
  # todo: come up with a more independent, extendible way to plug-in modules for different sites
  # todo: This is a *very* flaky idea, it works on the assumption that these sites don't have any major design changes. If they do, these modules need to be updated asap
  Sources = Hash[
    "www.collegiatetimes.com" => Hash[
      "name" => "Collegiate Times",
      "title" => "p.headline",
      "content" => "#story>p",
      "image" => ".img img",
      "url" => "http://www.collegiatetimes.com"
      ],
    # todo: extend this to support multiple blogs from roanoke.com. This is for "The Burgs"
    "blogs.roanoke.com" => Hash[
      "name" => "The Burgs Blog",
      "title" => "#post>h1",
      "content" => "#post>p",
      "image" => nil,
      "url" => "http://blogs.roanoke.com/theburgs"
      ],
    "www.roanoke.com" => Hash[
      "name" => "Roanoke Times",
      "title" => "#main h1",
      "content" => "#story-text>p",
      "image" => nil,
      "url" => "http://www.roanoke.com"
      ],
    "www.vtnews.vt.edu" => Hash[
      "name" => "Virginia Tech News",
      "title" => "h2.vt_pr_storytitle",
      "content" => "#vt_pr_content_body>p",
      "image" => "#vt_pr_storyimage img",
      "url" => "http://www.vtnews.vt.edu"
      ],
    "www.bev.net" => Hash[
      "name" => "Blacksburg Electronic Village",
      "title" => ".listingTitle",
      "content" => ".field-items p",
      "image" => nil,
      "url" => "http://www.bev.net"
      ],
    "www.blacksburg.va.us" => Hash[
      "name" => "Town of Blacksburg",
      "title" => "#_ctl0_titleLabel",
      "content" => "#_ctl0_content",
      "image" => nil,
      "url" => "http://www.blacksburg.va.us"
      ],
    "citizensfirstforblacksburg.org" => Hash[
      "name" => "Citizens First For Blacksburg",
      "title" => "#tabs-wrapper>h1",
      "content" => ".field-item>p",
      "image" => nil,
      "url" => "http://citizensfirstforblacksburg.org"
      ]
    ]

  # Fetches a page's HTML and then parses it to get story title, content and any images. Then saves the story.
  def parse
    require 'nokogiri'
    require 'net/http'
    require 'open-uri'
    url = params[:url]
    domain = url.split('/')[2]
    doc = Nokogiri::HTML(Net::HTTP.get(URI.parse(url)))

    if StoryFetcherController::Sources[domain] != nil
      name = StoryFetcherController::Sources[domain]["name"]
      @title = doc.css(StoryFetcherController::Sources[domain]["title"]).first.text
      @content = doc.css(StoryFetcherController::Sources[domain]["content"]).to_html.html_safe
      if StoryFetcherController::Sources[domain]["image"] != nil
        img_tags = doc.css(StoryFetcherController::Sources[domain]["image"])
        if !img_tags.empty?
          @image = "#{StoryFetcherController::Sources[domain]["url"]}#{img_tags.first['src']}"
        end
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

  def index
    @source_urls = StoryFetcherController::Sources.keys
  end
end