
require "facebook_data_fetcher.rb"
require "open-uri"

desc "Post stories to VTS from the cached facebook stories"

# Post the facebook stories from a
# "rss_cacher" (not opensource yet) installation
task :fbfetch, [:start_date, :end_date] => [:environment] do |t, args|
  begin
    args.with_defaults(:start_date => nil, :end_date => nil)

    if args.start_date
      start_date = Date.strptime(args.start_date, "%m/%d/%Y")
    else
      start_date = Time.now.in_time_zone('EST').to_date
    end

    if args.end_date
      end_date = Date.strptime(args.end_date, "%m/%d/%Y")
    else
      end_date = Time.now.in_time_zone('EST').to_date
    end

    start_date.upto(end_date) do |day|
      fetcher = FacebookDataFetcher.new(day)

      # Post stories
      fetcher.stories.each do |story|
        begin

          # check if the story already exists
          new_story = Story.find(:first, :conditions => {
            :fb_id => story["fb_id"]
          })

          if new_story
            puts "Story already exists: " + story["link"]
          else
            puts "Saving new story: " + story["link"]

            new_story = Story.new
            new_story.title = story["title"]
            new_story.views = 0
            new_story.kind = Story::Facebook
            new_story.source = story["author"]
            new_story.source_url = story["link"]
            new_story.published_at = story["published_at"]
            new_story.fb_id = story["fb_id"]
            new_story.fb_link = story["fb_link"]
            new_story.fb_likes_count = story["fb_likes_count"]
            new_story.fb_comments_count = story["fb_comments_count"]
            new_story.image_url = story["image_url"]
            new_story.description = story["text"]

            if story["fb_type"] == "status"
              new_story.fb_type = Story::FacebookTypeStatus
            elsif story["fb_type"] == "link"
              new_story.fb_type = Story::FacebookTypeLink
            else
              new_story.fb_type = Story::FacebookTypePhoto
            end

            new_story.save
            puts "Successfully saved story: " + story["link"]
          end

        rescue Exception => e
          puts e.message
          puts e.backtrace.inspect
        end
      end
    end
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
  end
end
