require 'rack'
require 'rack/test'
require 'rspec'

$:.push File.expand_path('../../lib', __FILE__)
require 'rack_subdomain'
require 'dummy/app'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
