class FeedsController < ApplicationController
  def latest
    @stories = Story.latest(nil, false)
    render :layout => false
    response.headers["Content-Type"] = "application/xml; charset=utf-8"
  end
end