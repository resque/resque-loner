module ResqueLoner
  module Resque
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      def push(queue, item)
        return "EXISTED" if loner_queued?(queue, item)
        if super(queue, item) == "OK"
          mark_loner_as_queued(queue, item)
        end
      end
      
      def pop(queue)
        item = super(queue)
        mark_loner_as_unqueued queue, item
        return item
      end

      def loner_queued?(queue, item)
        return false unless item_is_a_loner_job?(item)
        redis.get(loner_job_queue_key(queue, item)) == "1"
      end
      
      def mark_loner_as_queued(queue, item)
        return unless item_is_a_loner_job?(item)
        redis.set(loner_job_queue_key(queue, item), 1)
      end

      def mark_loner_as_unqueued(queue, item)
        return unless item_is_a_loner_job?(item)
        redis.del(loner_job_queue_key(queue, item))
      end

      def loner_job_queue_key(queue, item)
        job_key = constantize(item[:class] || item["class"]).redis_key(item[:args] || item["args"])
        "queue:#{queue}:loners:#{job_key}"
      end
      
      def item_is_a_loner_job?(item)
        klass = constantize(item[:class] || item["class"])
        klass.ancestors.include?(::Resque::LonerJob)
      end

    end
  end
end