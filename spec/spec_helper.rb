require 'rubygems'
require 'bundler/setup'
require 'rspec'

require 'ruby-debug'
require 'mock_redis'
require 'resque'
require 'resque-loner'

RSpec.configure do |config|
  config.before(:suite) do
    Resque.redis = MockRedis.new
  end
end
