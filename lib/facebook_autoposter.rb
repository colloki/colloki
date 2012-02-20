require "koala"

class FacebookAutoposter

  def initialize
    user_graph          = Koala::Facebook::API.new(Facebook::ACCESS_KEY)
    accounts            = user_graph.get_connections('me', 'accounts')
    page_access_token   = accounts[0]['access_token']
    @page_graph         = Koala::Facebook::GraphAPI.new(page_access_token)
  end

  def post(story)
    @page_graph.put_object(Facebook::PAGE_ID,
    'feed',
    :link => "http://vts.cs.vt.edu/stories/" + story.id.to_s)
  end

end