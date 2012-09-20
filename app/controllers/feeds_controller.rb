class FeedsController < ApplicationController
  def latest
    @stories = Story.latest_for_rss
    render :layout => false
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end
end
