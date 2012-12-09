require "twitter_data_fetcher.rb"
require "open-uri"
require "uri"

desc "Post stories to VTS from the cached twitter updates. BOOM."
# TODO: Combine parts of this with fbfetch.rake
task :twfetch, [:start_date, :end_date] => [:environment] do |t, args|
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
      fetcher = TwitterDataFetcher.new(day)

      # Post stories
      fetcher.stories.each do |story|
        begin

          # check if the story already exists
          new_story = Story.find(:first, :conditions => {
            :twitter_id => story["twitter_id"]
          })

          if new_story
            puts "Story already exists: " + story["id"].to_s
          else
            search_text = story["text"]
            #TODO: Move this into a separate class
            if search_text != ""
              urls = URI.extract(search_text, ["http", "https"])
              for url in urls
                puts "SHORT URL: " + url
                begin
                  # TODO: VERY VERY CRUDE and BAD way to check
                  # for validity of URL. Will fix.
                  open URI(url)
                  redirect = RedirectFollower.new(url).resolve
                  expanded_url = redirect.url.split("?")[0]
                  if expanded_url
                    existing_story = Story.find_by_url(expanded_url)
                  end
                rescue => e
                  puts e.message
                end
              end
            else
              puts "No Link Found"
            end

            new_story = Story.new
            new_story.title = story["text"]
            new_story.views = 0
            new_story.kind = Story::Twitter
            new_story.source = story["author"]
            new_story.source_url = "http://twitter.com/" + story["author"] + "/status/" + story["twitter_id"].to_s
            new_story.published_at = story["published_at"]
            new_story.twitter_id = story["twitter_id"]
            new_story.twitter_retweet_count = story["retweet_count"]
            new_story.latitude = story["latitude"]
            new_story.longitude = story["longitude"]

            if existing_story
              new_story.related_story_id = existing_story.id

              # Increase the external popularity of the existing story.
              puts "Increasing popularity of post: " + existing_story.title
              if (!existing_story.external_popularity)
                existing_story.external_popularity = 0
              end

              existing_story.external_popularity += 1
              if new_story.twitter_retweet_count
                existing_story.external_popularity += (Story::ScoreTwitterRetweet * new_story.twitter_retweet_count)
              end

              # Increment the twitter count
              existing_story.tweets_count += 1

              existing_story.save
            end

            new_story.save
            puts "Successfully saved story: " + story["id"].to_s
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
