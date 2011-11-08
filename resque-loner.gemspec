# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'resque-loner/version'

Gem::Specification.new do |s|
  s.name        = 'resque-loner'
  s.version     = Resque::Plugins::Loner::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Jannis Hermanns']
  s.email       = ['jannis@moviepilot.com']
  s.homepage    = 'http://github.com/jayniz/resque-loner'
  s.summary     = 'Adds unique jobs to resque'
  s.has_rdoc    = false

  s.rubyforge_project = 'resque-loner'

  s.add_dependency 'resque', '~>1.0'
  {
    'rake'                => '> 0.8.7',
    'rack-test'           => '~> 0.5.7',
    'rspec'               => '~> 2.5.0',
    'mock_redis'          => '~> 0.2.0',
    'yajl-ruby'           => '~> 0.8.2'
  }.each do |lib, version|
    s.add_development_dependency lib, version
  end

  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.description = <<desc
Makes sure that for special jobs, there can be only one job with the same workload in one queue.

Example:
    class CacheSweeper 

       include Resque::Plugins::UniqueJob

       @queue = :cache_sweeps

       def self.perform(article_id)
         # Cache Me If You Can...
       end
    end
desc
end
