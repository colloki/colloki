# Set up cron jobs

set :output, "log/cron.log"
set :environment, "development"

# run it at 6:45pm and 8:45am everyday
every 1.day, :at => '6:45pm, 8:45am' do
  rake "fetchandpost"
end