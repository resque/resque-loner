# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'resque-loner/version'

Gem::Specification.new do |s|
  s.name = 'resque-loner'
  s.version = Resque::Plugins::Loner::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Jannis Hermanns']
  s.email = ['jannis@moviepilot.com']
  s.homepage = 'http://github.com/jayniz/resque-loner'
  s.summary = 'Adds unique jobs to resque'
  s.has_rdoc = false
  s.license = 'MIT'

  s.rubyforge_project = 'resque-loner'

  s.add_dependency 'resque', '~>2.0'

  %w(
    airbrake
    i18n
    mocha
    mock_redis
    rack-test
    rake
    rspec
    rubocop
    simplecov
    yajl-ruby
  ).each do |gemname|
    s.add_development_dependency gemname
  end

  s.executables = `git ls-files -z -- bin/*`.split("\0").map do
    |f| File.basename(f)
  end
  s.files = `git ls-files -z`.split("\0")
  s.test_files = `git ls-files -z -- {test,spec,features}/*`.split("\0")
  s.require_paths = ['lib']

  s.description = <<-EODESC.gsub(/^ {4}/, '')
    Makes sure that for special jobs, there can be only one job with the same
    workload in one queue.

    Example:
        class CacheSweeper
           include Resque::Plugins::UniqueJob

           @queue = :cache_sweeps

           def self.perform(article_id)
             # Cache Me If You Can...
           end
        end
  EODESC
end
