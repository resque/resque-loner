dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'
$TESTING = true

require 'spec'

require 'rubygems'
require 'resque'
require 'lib/resque_loner'
require 'ruby-debug'

Spec::Runner.configure do |config|
  config.before(:suite) do
    if !system("which redis-server")
      puts '', "** can't find `redis-server` in your path"
      puts "** try running `sudo rake install`"
      abort ''
    end
    puts "Starting redis for testing at localhost:9736..."
    `redis-server #{File.dirname(File.expand_path(__FILE__))}/redis-test.conf`
    puts  "redis-server #{File.dirname(File.expand_path(__FILE__))}/redis-test.conf"
    Resque.redis = 'localhost:9736'
  end
  
  config.after(:suite) do
    pid = `ps -e -o pid,command | grep [r]edis-test`.split(" ")[0]
    puts "Killing test redis server #{pid}..."
    `rm -f #{File.dirname(File.expand_path(__FILE__))}/dump.rdb`
    Process.kill("KILL", pid.to_i)
  end
end