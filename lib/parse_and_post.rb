module ParseAndPost
  # todo: come up with a more independent, extendible way to plug-in modules for different sites
  # todo: This is a *very* flaky idea, it works on the assumption that these sites don't have any major design changes. If they do, these modules need to be updated asap
  # todo: add field for original author of article
  Sources = Hash[
    # Collegiate Times
    "www.collegiatetimes.com" => Hash[
      "name" => "Collegiate Times",
      "title" => "p.headline",
      "content" => "#story>p",
      "image" => ".img img",
      "url" => "http://www.collegiatetimes.com"
      ],
    # The Burgs
    "blogs.roanoke.com" => Hash[
      "name" => "The Burgs",
      "title" => "#post>h1",
      "content" => "#post>p",
      "image" => "#post img:not([alt=Share])",
      "url" => "http://blogs.roanoke.com/theburgs"
      ],
    # Roanoke Times
    "www.roanoke.com" => Hash[
      "name" => "Roanoke Times",
      "title" => "#main h1",
      "content" => "#story-text>p",
      "image" => "#story-add-photos>img",
      "url" => "http://www.roanoke.com"
      ],
    # Virginia Tech News
    "www.vtnews.vt.edu" => Hash[
      "name" => "Virginia Tech News",
      "title" => "h2.vt_pr_storytitle",
      "content" => "#vt_pr_content_body>p",
      "image" => "#vt_pr_storyimage img",
      "url" => "http://www.vtnews.vt.edu"
      ],
    # Blacksburg Electronic Village
    "www.bev.net" => Hash[
      "name" => "Blacksburg Electronic Village",
      "title" => ".listingTitle",
      "content" => ".field-items p",
      "image" => nil,
      "url" => "http://www.bev.net"
      ],
    # Town of Blacksburg
    "www.blacksburg.va.us" => Hash[
      "name" => "Town of Blacksburg",
      "title" => "#_ctl0_titleLabel",
      "content" => "#_ctl0_content",
      "image" => nil,
      "url" => "http://www.blacksburg.va.us"
      ],
    # Citizens First for Blacksburg
    "citizensfirstforblacksburg.org" => Hash[
      "name" => "Citizens First For Blacksburg",
      "title" => "#tabs-wrapper>h1",
      "content" => ".field-item>p",
      "image" => nil,
      "url" => "http://citizensfirstforblacksburg.org"
      ],
    # Christiansburg Virginia
    "www.christiansburg.org" => Hash[
      "name" => "Christiansburg Virginia",
      "title" => ".item>h3",
      "content" => ".content>p",
      "image" => nil,
      "url" => "http://www.christiansburg.org"
      ],
    # Downtown Blacksburg
    "downtownblacksburg.wordpress.com" => Hash[
      "name" => "Downtown Blacksburg Blog",
      "title" => "h1.title",
      "content" => ".entry>p",
      "image" => ".entry img",
      "url" => "http://downtownblacksburg.files.wordpress.com"
      ],
    # Depotdazed blog
    "www.myvaresources.com" => Hash[
      "name" => "Depotdazed",
      "title" => "h2.post-title > a",
      "content" => ".post-body>p",
      "image" => "p.wp-caption-dt img",
      "url" => "http://www.myvaresources.com/blogs/depotdazed"
      ],
    # NRV News
    "nrvnews.com" => Hash[
      "name" => "NRV News",
      "title" => "h1.title",
      "content" => ".module-inner2",
      "image" => ".module-inner2 img"
      ],
    # SWVA Today
    "www2.swvatoday.com" => Hash[
      "name" => "SWVA Today",
      "title" => "h1.story_headline",
      "content" => ".entry-content p",
      "image" => ".img img"
      ],
    # The Southwest Times
    "www.southwesttimes.com" => Hash[
      "name" => "The Southwest Times",
      "title" => "h1.entry_title",
      "content" => ".post p",
      "image" => ".post img"
      ]
    ]

  def self.run(url, topic)
    require 'nokogiri'
    require 'net/http'
    require 'open-uri'

    domain = url.split('/')[2]

    if Sources.has_key?(domain)
      # check if the story already exists. if yes, return it, instead of reposting it
      story = Story.find(:first, :conditions => {:source_url => url})
      if story
        if topic and story.topic != topic
          story.topic = topic
          story.save
        end
      else
        name = Sources[domain]["name"]
        response = RedirectFollower.new(url, 3).resolve

        doc = Nokogiri::HTML(response.body)

        #todo: Have a stronger check here to determine if a document is parseable
        if doc.title()
          @title = doc.css(Sources[domain]["title"]).first.text
          @image = nil

          if Sources[domain]["image"] != nil
            img_tags = doc.css(Sources[domain]["image"])
            if !img_tags.empty?
              src = img_tags.first['src']
              if (src.index(Sources[domain]["url"]))
                @image = "#{src}"
              else
                @image = "#{Sources[domain]["url"]}#{src}"
              end
            end
          end

          @content = doc.css(Sources[domain]["content"])
          # get rid of any images, since we are already storing images separately
          @content.xpath("//img").remove
          @content = @content.to_html.html_safe

          # save the fetched story
          story = Story.new
          story.title = @title
          story.description = @content
          if topic
            story.topic = topic
          else
            story.topic_id = -1
          end
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
  end
end