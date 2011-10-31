desc "Automatically post stories to Colloki from the cached rss stories"

task :fetchandpost => :environment do
  include ParseAndPost
  require 'net/http'
  require 'csv'

  # todo: put this into a config file somewhere
  source = "http://happy.cs.vt.edu/collokimining/"

  # fetch them for today. date format is DDMonYY
  today = Date.today
  d = today.strftime('%d')
  mon = Date::MONTHNAMES[Integer(today.strftime('%m'))].to(2)
  y = today.strftime('%y')
  date = d << mon << y

  file_path = source << date << "/stories.csv"
  stories_csv = Net::HTTP.get_response(URI.parse(file_path)).body

  CSV.parse(stories_csv) do |row|
    ParseAndPost::run(row[3])
  end

  # todo: add a reference to the associated topics to each story
  # todo: create a separate topics table for this
end