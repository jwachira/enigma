$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'enigma'
require 'sinatra/base'
require 'spec'
require 'spec/autorun'
require File.dirname(__FILE__) + '/rack_test_client'

Spec::Runner.configure do |config|
  
end
