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

    autoload :Jobber, File.join(REDISCULE_LIB_DIR, 'rediscule/jobber')
    autoload :Configurator, File.join(REDISCULE_LIB_DIR, 'rediscule/configurator')
    autoload :Job, File.join(REDISCULE_LIB_DIR, 'rediscule/job')
    autoload :DurableJob, File.join(REDISCULE_LIB_DIR, 'rediscule/durable_job')
    autoload :Worker, File.join(REDISCULE_LIB_DIR, 'rediscule/worker')
    autoload :Daemon, File.join(REDISCULE_LIB_DIR, 'rediscule/daemon')
    autoload :Janitor, File.join(REDISCULE_LIB_DIR, 'rediscule/janitor')
    autoload :DaemonPuppet, File.join(REDISCULE_LIB_DIR, 'rediscule/daemon_puppet')
    autoload :JanitorPuppet, File.join(REDISCULE_LIB_DIR, 'rediscule/janitor_puppet')

    autoload :Async, File.join(REDISCULE_LIB_DIR, 'rediscule/async')
    autoload :AsyncWorker, File.join(REDISCULE_LIB_DIR, 'rediscule/async_worker')
    
    class RedisculeError < StandardError; end

    def self.json_encode(o)
      Yajl::Encoder.encode(o)
    end

    def self.json_decode(o)
      Yajl::Parser.parse(o)
    end

    def self.jobber; @@jobber; end
    def self.jobber=(i); @@jobber = i; end

    def self.configure(&block)
      Configurator.configure(&block)
    end
  end
end
