# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'resque-loner/version'
 
Gem::Specification.new do |s|
  s.name        = "resque-loner"
  s.version     = Resque::Plugins::Loner::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jannis Hermanns"]
  s.email       = ["jannis@moviepilot.com"]
  s.homepage    = "http://github.com/jayniz/resque-loner"
  s.summary     = "Adds unique jobs to resque"
  s.has_rdoc    = false
  
  s.rubyforge_project         = "resque-loner"
  s.add_dependency 'resque', "< 2.0.0"
  s.add_development_dependency "rspec"
 
  s.files        = Dir.glob("{lib}/**/*") + %w(README.markdown)
  s.require_path = 'lib'

  s.description =  <<desc
Makes sure that for special jobs, there can be only one job with the same workload in one queue.

Example:
    class CacheSweeper < Resque::Plugins::Loner::UniqueJob
       @queue = :cache_sweeps
    
       def self.perform(article_id)
         # Cache Me If You Can...
       end
    end
desc
end
