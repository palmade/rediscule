module Palmade::Rediscule
  class Job
    include Constants

   DEFAULT_OPTIONS = {
      :cache_classes => true,
      :origin => Cself,
      :queue_klass => nil,
      :queue_key_prefix => nil,
      :queue_options => { }
    }

    Cdefault_queue_key_prefix = "rediscule/job/%s".freeze

    attr_reader :job_key
    attr_reader :config
    attr_reader :options
    attr_reader :logger
    attr_reader :jobber
    attr_reader :origin

    def self.create(jobber, job_k, options = { }, config = { })
      self.new(jobber, job_k, options, config).build!
    end

    def initialize(jobber, job_k, options = { }, config = { })
      @jobber = jobber
      @logger = jobber.logger
      @job_key = job_k
      @options = DEFAULT_OPTIONS.merge(options)
      @config = config

      @origin = @options[:origin]

      if @options[:queue_key_prefix].nil?
        @options[:queue_key_prefix] = sprintf(Cdefault_queue_key_prefix, @job_key)
      end

      @worker_klass = nil
    end

    def build!
      self
    end

    def order(action, params = { })
      queue.push(create_unit(action, params))
    end

    def perform(item, unit)
      worker_klass.perform(self, item, unit)
    end

    def reserve
      queue.pop
    end

    def maintain
      # do nothing
    end

    def queue
      if defined?(@queue)
        @queue
      else
       case @options[:queue_klass]
        when Class
          queue_klass = @options[:queue_klass]
        when String
          queue_klass = eval(@options[:queue_klass], TOPLEVEL_BINDING)
        when nil
          queue_klass = default_queue_klass
        else
          raise "Unsupported queue klass #{@options[:queue_klass].inspect}"
        end

        @queue = queue_klass.new(@options[:queue_key_prefix],
                                 @options[:queue_options])
      end
    end

    def set_rcache(rcache)
      queue.set_rcache(rcache)
    end

    def destroy
      queue.destroy
    end

    protected

    def default_queue_klass
      Palmade::Rediscule::BaseQueue
    end

    def create_unit(action, params = { })
      {
        Cjobkey => job_key,
        Caction => action,
        Cparams => params,
        Corigin => origin
      }
    end

    def worker_klass
      if !@options[:cache_classes] || @worker_klass.nil?
        worker_name = @options[:class_name]
        unless worker_name.nil?
          @worker_klass = eval(worker_name, TOPLEVEL_BINDING)
        else
          raise ArgumentError, "Worker class name not defined"
        end
      else
        @worker_klass
      end
    end
  end
end
