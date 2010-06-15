require 'lib/resque_loner/job'
require 'lib/resque_loner/loner_job'

Resque::Job.class_eval do
  include ResqueLoner::Job
end