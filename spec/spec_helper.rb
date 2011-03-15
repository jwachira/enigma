$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'enigma'
require 'sinatra/base'
require 'rspec'
require File.dirname(__FILE__) + '/rack_test_client'

RSpec.configure do |config|
  
end
