$LOAD_PATH.unshift 'lib'

require 'rubygems'
require 'bundler'
Bundler.setup

require 'rspec/core/rake_task'
load 'tasks/redis.rake'
require 'rake/testtask'
require 'resque/tasks'
require 'bundler/gem_tasks'

def command?(command)
  system("type #{command} > /dev/null 2>&1")
end

task default: :spec

desc 'Run specs for resque-loner'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = %w(-fd -c)
end

if command?(:rg)
  desc 'Run the test suite with rg'
  task :test do
    Dir['test/**/*_test.rb'].each do |f|
      sh("rg #{f}")
    end
  end
else
  Rake::TestTask.new do |test|
    test.libs << 'test'
    test.test_files = FileList['test/**/*_test.rb']
  end
end

if command? :kicker
  desc 'Launch Kicker (like autotest)'
  task :kicker do
    puts 'Kicking... (ctrl+c to cancel)'
    exec 'kicker -e rake test lib examples'
  end
end

task :install => ['redis:install', 'dtach:install']

begin
  require 'sdoc_helpers'
rescue LoadError
end
