desc "Automatically post stories to Colloki from the cached rss stories"

task :fetchandpost => :environment do
  include ParseAndPost
  require "net/http"
  require "csv"

  begin
    # todo: put this into a config file somewhere
    source = "http://happy.cs.vt.edu/collokimining/"

    # fetch them for today. date format is DDMonYY
    today = Date.today
    d = today.strftime("%d")
    mon = Date::MONTHNAMES[Integer(today.strftime("%m"))].to(2)
    y = today.strftime("%y")
    date = d << mon << y

    # todo: get all the topics and store them (if unique)

    # get all the stories for today and post them (if unique)
    stories_file_path = source << date << "/stories.csv"

    stories_csv = Net::HTTP.get_response(URI.parse(stories_file_path)).body

    CSV.parse(stories_csv) do |row|
      ParseAndPost::run(row[3])
    end
  rescue

  end
end