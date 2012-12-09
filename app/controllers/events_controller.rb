class EventsController < ApplicationController
  require 'open-uri'
  require 'json'

  def index
    url = 'http://elmcity.cloudapp.net/NewRiverValleyVA/json'
    events = JSON.parse(open(url).read)

    # If a date is given, filter out events except the specified date
    # Date is expected in the yyyy-mm-dd format
    if params[:date] != nil
      date = Time.parse(params[:date]).to_date

      events = events.select { |event|
        eventDate = Time.parse(event['dtstart']).localtime.to_date
        eventDate == date
      }
    end

    # Group together the events with the same time
    @grouped_events = Hash.new
    id = 0;

    for event in events
      event['id'] = id
      id = id + 1

      # Split comma separated categories into an array
      event['categories'] = event['categories'].split(',')

      # Convert times to local timezone
      event['dtstart'] = Time.parse(event['dtstart']).localtime
      event['dtend'] = Time.parse(event['dtend']).localtime

      if @grouped_events.has_key? event['dtstart']
        @grouped_events[event['dtstart']].push(event)
      else
        @grouped_events[event['dtstart']] = [event]
      end
    end

    respond_to do |format|
      format.json {render :json => @grouped_events}
    end
  end
end
