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
  
  def self.enqueued?( klass, *args)
    enqueued_in?(queue_from_class(klass), klass, *args )
  end
  
  def self.enqueued_in?(queue, klass, *args)
    item = { :class => klass.to_s, :args => args }
    return nil unless Resque::Plugins::Loner::Helpers.item_is_a_loner_job?(item)
    Resque::Plugins::Loner::Helpers.loner_queued?(queue, item)
  end
  
end