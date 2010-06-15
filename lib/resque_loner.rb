require 'rubygems'
require 'resque'
require 'lib/resque_loner/loner_job'
require 'lib/resque_loner/resque'

Resque.class_eval do
  include ResqueLoner::Resque
end