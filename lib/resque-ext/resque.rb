module Resque
  
  #
  #  Why force one job type into one queue?
  #
  def self.enqueue_in( queue, klass, *args )
    Job.create(queue, klass, *args)
  end
  
end