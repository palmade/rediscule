module Palmade::Rediscule
  class Configurator
    def self.configure(&block)
      self.new.configure(&block)
    end

    def initialize
      @jobber = nil
      @configured = false
      @finalized = false
      @default_job_options = { }
    end

    def configure(&block)
      self.instance_eval(&block)
      finalize unless @finalized

      self
    end

    def init(root_path, env)
      @jobber = Jobber.init(root_path, env)
    end

    def config(config_path = nil)
      jobber_required
      @configured = true
      @jobber.configure(config_path)
    end

    def set_logger(l)
      jobber_required
      @jobber.set_logger(l)
    end

    def set_job_options(hash = { })
      @default_job_options.update(hash)
    end

    def map_job(job_k, options = { })
      jobber_required
      @jobber.map_job(job_k, @default_job_options.merge(options))
    end

    def map_async_jobs(job_k,
                       options = { })
      jobber_required
      @jobber.map_job(job_k, {
                        :class_name => 'Palmade::Rediscule::AsyncWorker',
                        :type => :durable
                      }.merge(@default_job_options).merge(options))
    end

    def finalize
      jobber_required
      config unless @configured

      @finalized = true
      @jobber.finalize
    end

    protected

    def jobber_required
      raise "jobber required for this stage" if @jobber.nil?
    end
  end
end
