class StoryFetcherController < ApplicationController
  include ParseAndPost
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