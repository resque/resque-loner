module Resque
#  module Plugins
#    module Loner
      class Job
        
        
        #
        #  Overwriting original create method to mark an item as queued
        #  after Resque::Job.create has called Resque.push
        #
        def self.create_with_loner(queue, klass, *args)
          item = { :class => klass.to_s, :args => args }
          return "EXISTED" if Resque::Plugins::Loner::Helpers.loner_queued?(queue, item)
          create_without_loner(queue, klass, *args)
          Resque::Plugins::Loner::Helpers.mark_loner_as_queued(queue, item)
        end
        
        #
        #  Overwriting original reserve method to mark an item as unqueued
        #
        def self.reserve_with_loner(queue)
          item = reserve_without_loner(queue)
          Resque::Plugins::Loner::Helpers.mark_loner_as_unqueued( queue, item ) if item
          item
        end
        
        #
        #  Overwriting original destroy method to mark all destroyed jobs as unqueued
        #
        def self.destroy_with_loner(queue, klass, *args)
          Resque::Plugins::Loner::Helpers.job_destroy(queue, klass, *args)
          destroy_without_loner(queue, klass, *args)
        end
        
        class << self
          alias_method :create_without_loner, :create
          alias_method :create, :create_with_loner
          alias_method :reserve_without_loner, :reserve
          alias_method :reserve, :reserve_with_loner
          alias_method :destroy_without_loner, :destroy
          alias_method :destroy, :destroy_with_loner
        end
      end
#    end
#  end
end