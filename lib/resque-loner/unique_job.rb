require 'digest/md5'

#
#  If you want your job to be unique, include this module in it. If you wish,
#  you can overwrite this implementation of redis_key to fit your needs
#
module Resque
  module Plugins
    module UniqueJob

      def self.included(base)
        base.extend         ClassMethods
        base.class_eval do
          base.send(:extend, Resque::Helpers)
        end
      end # self.included

      module ClassMethods


        #
        #  Payload is what Resque stored for this job along with the job's class name.
        #  On a Resque with no plugins installed, this is a hash containing :class and :args
        #
        def redis_key(payload)
          payload = decode(encode(payload)) # This is the cycle the data goes when being enqueued/dequeued
          job  = payload[:class] || payload["class"]
          args = (payload[:args]  || payload["args"])
          args.map! do |arg|
            arg.respond_to?(:sort) ? arg.sort : arg
          end

          digest = Digest::MD5.hexdigest encode(:class => job, :args => args)
          digest
        end
      end # ClassMethods


    end
  end
end

module Resque
  module Plugins
    module Loner
      class UniqueJob

        include Resque::Plugins::UniqueJob

        def self.inherited(host)
          super(host)
          return  if @__unique_job_warned
          warn "Inherit Resque::Plugins::Loner::UniqueJob is deprecated. Include Resque::Plugins::UniqueJob module instead."
          @__unique_job_warned = true
        end
      end
    end
  end
end
