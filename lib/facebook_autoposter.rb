require "koala"

class FacebookAutoposter

  def self.run
    user_graph        = Koala::Facebook::API.new(Facebook::ACCESS_KEY)
    accounts          = user_graph.get_connections('me', 'accounts')
    page_access_token = accounts[0]['access_token']
    page_graph        = Koala::Facebook::GraphAPI.new(page_access_token)

    # page_graph.put_object(Facebook::PAGE_ID, 'feed', :message => 'This is posted as the user')
  end

end