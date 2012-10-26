# Load the rails application
require File.expand_path('../application', __FILE__)
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

# Initialize the rails application
Colloki::Application.initialize!

require 'validates_uri_existence_of'
Time::DATE_FORMATS[:cool] = "%A, %B %d, %Y"

# path to ImageMagick
Paperclip.options[:command_path] = "/usr/local/bin/"

require "will_paginate/array"
