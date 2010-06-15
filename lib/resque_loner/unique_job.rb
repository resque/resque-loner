require 'digest/md5'

#
#  If you want your job to be unique, subclass it from this class. If you wish,
#  you can overwrite this implementation of redis_key to fit your needs
#
module Resque
  module Plugins
    module Loner
      class UniqueJob
        extend Resque::Helpers

        #
        #  Payload is what Resque stored for this job along with the job's class name.
        #  On a Resque with no plugins installed, this is a hash containing :class and :args
        #
        def self.redis_key(payload)
          payload = decode(encode(payload)) # This is the cycle the data goes when being enqueued/dequeued
          job  = payload[:class] || payload["class"]
          args = payload[:args]  || payload["args"]
          digest = Digest::MD5.hexdigest encode(:class => job, :args => args)
          digest
        end
      end
    end
  end
end