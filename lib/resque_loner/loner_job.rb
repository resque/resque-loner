require 'digest/md5'

module Resque
  class LonerJob
    extend Resque::Helpers
    
    def self.redis_key(values)
      Digest::MD5.hexdigest encode(values)
    end
  end
end