xml.instruct! :xml, :version => "1.0" 
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Virtual Town Square Latest"
    xml.description "Latest issues and news in Blacksburg and Montgomery county"
    xml.link stories_url

    for story in @stories
      xml.item do
        xml.title story.title
        xml.description story_image(story) + sanitize(story.description)
        xml.pubDate story.published_at.to_s(:rfc822)
        xml.link story_url(story)
        xml.guid story_url(story)
      end
    end
  end
end