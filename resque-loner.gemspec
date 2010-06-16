# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'resque_loner/version'
 
Gem::Specification.new do |s|
  s.name        = "resque-loner"
  s.version     = Resque::Plugins::Loner::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jannis Hermanns"]
  s.email       = ["jannis@moviepilot.com"]
  s.homepage    = "http://github.com/jayniz/resque-loner"
  s.summary     = "Adds unique jobs to resque"
  s.description = "Makes sure that for special jobs, there can be only one job with the same workload in one queue."
 
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "bundler"
 
  s.add_development_dependency "rspec"
 
  s.files        = Dir.glob("{lib}/**/*") + %w(README.markdown)
  s.require_path = 'lib'
end