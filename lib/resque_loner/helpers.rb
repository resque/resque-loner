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
          return unless item_is_a_loner_job?(job.payload)
          redis.del(loner_job_queue_key(queue, job.payload))
        end

        def self.loner_job_queue_key(queue, item)
          job_key = constantize(item[:class] || item["class"]).redis_key(item)
          "loners:queue:#{queue}:job:#{job_key}"
        end
      
        def self.item_is_a_loner_job?(item)
          klass = constantize(item[:class] || item["class"])
          klass.ancestors.include?(::Resque::Plugins::Loner::LonerJob)
        end
      end
    end
  end
end