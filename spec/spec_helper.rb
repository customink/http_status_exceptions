require 'rubygems'
require 'bundler'

Bundler.setup

require 'http_status_exceptions'

RSpec.configure do |config|
  config.mock_with :rspec
end
