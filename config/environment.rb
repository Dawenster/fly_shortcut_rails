# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
FlyShortcutRails::Application.initialize!

require 'rubygems'
require 'pry'
require 'pry_debug'
require 'uri'
require 'pg'
require 'csv'
require 'twitter-bootstrap-rails'

ONE_DAY = 60*60*24
ONE_HOUR = 60*60