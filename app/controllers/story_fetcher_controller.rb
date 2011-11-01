class StoryFetcherController < ApplicationController
  include ParseAndPost
  # todo: come up with a more independent, extendible way to plug-in modules for different sites
  # todo: This is a *very* flaky idea, it works on the assumption that these sites don't have any major design changes. If they do, these modules need to be updated asap
  # todo: add field for original author of article
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
      "image" => "#post img",
      "url" => "http://blogs.roanoke.com/theburgs"
      ],
    "www.roanoke.com" => Hash[
      "name" => "Roanoke Times",
      "title" => "#main h1",
      "content" => "#story-text>p",
      "image" => "#story-add-photos>img",
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
      ],
    "www.christiansburg.org" => Hash[
      "name" => "Christiansburg Virginia",
      "title" => ".item>h3",
      "content" => ".content>p",
      "image" => nil,
      "url" => "http://www.christiansburg.org"
      ],
    "downtownblacksburg.wordpress.com" => Hash[
      "name" => "Downtown Blacksburg Blog",
      "title" => "h1.title",
      "content" => ".entry>p",
      "image" => ".entry img",
      "url" => "http://downtownblacksburg.files.wordpress.com"
      ]
    ]
    Sources.default = nil

  def index
    @source_urls = StoryFetcherController::Sources.keys
  end

  # Fetches a page's HTML and then parses it to get story title, content and any images. Then saves the story.
  def parse
    ParseAndPost::run(params[:url])
  end

  def autopost
    system "rake fetchandpost --trace >> #{Rails.root}/log/rake.log"
  end
end