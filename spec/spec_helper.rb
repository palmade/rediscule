require 'rubygems'

gem 'redis'
require 'redis'

gem 'yajl-ruby'
require 'yajl'

require 'pp'

require File.expand_path(File.join(File.dirname(__FILE__), '../lib/palmade/rediscule'))

SPEC_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..'))
SPEC_ENV = "test"

SPEC_BASE_QUEUE = "rediscule/spec/base_queue"
SPEC_DURABLE_QUEUE = "rediscule/spec/durable_queue"

module Palmade::Rediscule
  module SpecHelper
    def self.rcache=(r); @@rcache = r; end
    def self.rcache; @@rcache; end

    def self.connect_to_redis
      self.rcache = Redis.new(:host => '127.0.0.1',
                              :port => '6380',
                              :db => '0')
    end
  end
end

class TestWorker < Palmade::Rediscule::Worker
end
