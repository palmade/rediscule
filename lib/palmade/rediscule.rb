require 'logger'
require 'benchmark'

REDISCULE_LIB_DIR = File.expand_path(File.dirname(__FILE__))

module Palmade
  module Rediscule
    autoload :BaseItem, File.join(REDISCULE_LIB_DIR, 'rediscule/base_item')
    autoload :BaseQueue, File.join(REDISCULE_LIB_DIR, 'rediscule/base_queue')
    autoload :DurableItem, File.join(REDISCULE_LIB_DIR, 'rediscule/durable_item')
    autoload :DurableQueue, File.join(REDISCULE_LIB_DIR, 'rediscule/durable_queue')
    autoload :Constants, File.join(REDISCULE_LIB_DIR, 'rediscule/constants')

    def self.json_encode(o)
      Yajl::Encoder.encode(o)
    end

    def self.json_decode(o)
      Yajl::Parser.parse(o)
    end
  end
end
