require 'rubygems'
require 'bundler/setup'

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'English'
require 'simplecov'

require 'rspec'

require 'resque'
require 'resque-loner'

module Support
  class << self
    attr_accessor :redis_pid
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    unless ENV['RESQUE_SCHEDULER_DISABLE_TEST_REDIS_SERVER']
      # Start our own Redis when the tests start. RedisInstance will take care of
      # starting and stopping.
      require File.expand_path('../support/redis_instance', __FILE__)
      RedisInstance.run!
    end
  end
end
