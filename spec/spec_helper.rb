require 'rubygems'
require 'bundler'

Bundler.setup(:default, :development)

require 'spec'
require 'spec/autorun'
require 'mocha'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(File.dirname(__FILE__)), 'lib'))

require 'mongoid_attr_accessible'

def fixture_path(path)
  File.join(File.dirname(__FILE__), 'fixtures', path)
end

Mongoid.configure do |config|
  # Turn this nasty thing on to make sure we actually disable it correctly.
  config.allow_dynamic_fields = true

  # Connect to our database.
  config.master = Mongo::Connection.new.db('mongoid_attr_accessible_test')
end

Spec::Runner.configure do |config|  
end
