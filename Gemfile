source 'http://rubygems.org'
gemspec

group :development do
  gem 'gemcutter'
  gem 'ruby-debug', :platform => :mri_18
  gem 'debugger', :platform => :mri_19
end

group :test do
  gem "rake"
  gem "rack-test", "~> 0.5"
  gem "mocha", "~> 0.9.7"
  gem "yajl-ruby", "~>0.8.2", :platforms => :mri
  gem "json", "~>1.5.3", :platforms => [:jruby, :rbx]
  gem "hoptoad_notifier"
  gem "airbrake"
  gem "i18n"
end
