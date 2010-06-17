module Resque
  
  #
  #  Why force one job type into one queue?
  #
  def self.enqueue_to( queue, klass, *args )
    Job.create(queue, klass, *args)
  end
  
  def self.dequeue_from( queue, klass, *args)
    Job.destroy(queue, klass, *args)
  end
  
end