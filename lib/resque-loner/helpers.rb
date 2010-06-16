module Resque
  module Plugins
    module Loner
      class Helpers
        extend Resque::Helpers

        def self.loner_queued?(queue, item)
          return false unless item_is_a_loner_job?(item)
          redis.get(loner_job_queue_key(queue, item)) == "1"
        end
      
        def self.mark_loner_as_queued(queue, item)
          return unless item_is_a_loner_job?(item)
          redis.set(loner_job_queue_key(queue, item), 1)
        end

        def self.mark_loner_as_unqueued(queue, job)
          item = job.is_a?(Resque::Job) ? job.payload : job
          return unless item_is_a_loner_job?(item)
          redis.del(loner_job_queue_key(queue, item))
        end

        def self.loner_job_queue_key(queue, item)
          job_key = constantize(item[:class] || item["class"]).redis_key(item)
          "loners:queue:#{queue}:job:#{job_key}"
        end
      
        def self.item_is_a_loner_job?(item)
          begin
            klass = constantize(item[:class] || item["class"])
            klass.ancestors.include?(::Resque::Plugins::Loner::UniqueJob)
          rescue
            false
          end
        end
        
        def self.job_destroy(queue, klass, *args)
          klass = klass.to_s
          redis_queue = "queue:#{queue}"

          redis.lrange(redis_queue, 0, -1).each do |string|
            json   = decode(string)

            match  = json['class'] == klass
            match &= json['args'] == args unless args.empty?

            if match
             Resque::Plugins::Loner::Helpers.mark_loner_as_unqueued( queue, json )
            end
          end
        end
        
      end
    end
  end
end