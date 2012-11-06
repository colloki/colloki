class FeedsController < ApplicationController
  def latest
    @stories = Story.latest_for_rss
    respond_to do |format|
      format.xml
    end
  end
end
