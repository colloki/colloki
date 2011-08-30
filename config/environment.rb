# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Colloki::Application.initialize!

require 'validates_uri_existence_of'
Time::DATE_FORMATS[:cool] = "%A, %B %d, %Y"