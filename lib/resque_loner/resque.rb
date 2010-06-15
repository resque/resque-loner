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

      def loner_queued?(queue, item)
        klass = constantize(item[:class])
        return false unless klass.ancestors.include?(::Resque::LonerJob)
        redis.get(loner_job_queue_key(queue, klass.redis_key(item[:args]))) == "1"
      end
      
      def mark_loner_as_queued(queue, item)
        klass = constantize(item[:class])
        return false unless klass.ancestors.include?(::Resque::LonerJob)
        debugger
        redis.set(loner_job_queue_key(queue, klass.redis_key(item[:args])), 1)
      end

      def loner_job_queue_key(queue, job_key)
        "queue:#{queue}:loners:#{job_key}"
      end
    end
  end
end