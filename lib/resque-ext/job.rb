#
#  Since there were not enough hooks to hook into, I have to overwrite
#  3 methods of Resque::Job - the rest of the implementation is in the
#  proper Plugin namespace.
# 
module Resque
  class Job


    #
    #  Overwriting original create method to mark an item as queued
    #  after Resque::Job.create has called Resque.push
    #
    def self.create_with_loner(queue, klass, *args)
      return create_without_loner(queue, klass, *args) if Resque.inline?
      item = { :class => klass.to_s, :args => args }
      return "EXISTED" if Resque::Plugins::Loner::Helpers.loner_queued?(queue, item)
      job = create_without_loner(queue, klass, *args)
      Resque::Plugins::Loner::Helpers.mark_loner_as_queued(queue, item)
      job
    end

    #
    #  Overwriting original reserve method to mark an item as unqueued
    #
    def self.reserve_with_loner(queue)
      item = reserve_without_loner(queue)
      Resque::Plugins::Loner::Helpers.mark_loner_as_unqueued( queue, item ) if item && !Resque.inline?
      item
    end

    #
    #  Overwriting original destroy method to mark all destroyed jobs as unqueued.
    #  Because the original method only returns the amount of jobs destroyed, but not 
    #  the jobs themselves. Hence Resque::Plugins::Loner::Helpers.job_destroy looks almost
    #  as the original method Resque::Job.destroy. Couldn't make it any dry'er.
    #
    def self.destroy_with_loner(queue, klass, *args)
      Resque::Plugins::Loner::Helpers.job_destroy(queue, klass, *args) unless Resque.inline?
      destroy_without_loner(queue, klass, *args)
    end

    #
    # Chain..
    #
    class << self
      alias_method :create_without_loner, :create
      alias_method :create, :create_with_loner
      alias_method :reserve_without_loner, :reserve
      alias_method :reserve, :reserve_with_loner
      alias_method :destroy_without_loner, :destroy
      alias_method :destroy, :destroy_with_loner
    end
  end
end
