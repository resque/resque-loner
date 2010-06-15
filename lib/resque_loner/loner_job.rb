require 'digest/md5'

module Resque
  module Plugins
    module Loner
      class LonerJob
        extend Resque::Helpers

        def self.redis_key(item)
          job  = item[:class] || item["class"]
          args = item[:args]  || item["args"]
          digest = Digest::MD5.hexdigest encode(:class => job, :args => args)
          digest
        end
      end
    end
  end
end