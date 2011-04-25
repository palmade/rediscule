module Palmade::Rediscule
  class Daemon
    include Constants

    DEFAULT_OPTIONS = {
      :middlware => nil
    }

    attr_reader :job_keys
    attr_reader :jobber
    attr_reader :logger

    def self.start(jobber, job_keys = :all, options = { })
      new(jobber, job_keys, options).start
    end

    def initialize(jobber, job_keys = :all, options = { })
      @options = DEFAULT_OPTIONS.merge(options)
      @jobber = jobber
      @logger = jobber.logger
      @job_keys = job_keys
      @job_cycles = nil

      @middleware = @options[:middleware]
    end

    def start
      case @job_keys
      when :all
        @job_keys = jobber.jobs.keys.dup
      when String, Symbol
        @job_keys = [ @job_keys.to_s ]
      when Array
        @job_keys = @job_keys.collect { |jk| jk.to_s.freeze }
      else
        raise "Unsupported job_keys argument"
      end

      @job_keys.each do |jk|
        unless jobber.jobs.include?(jk)
          raise "Job #{jk} not defined"
        end
      end

      @job_cycles = @job_keys.dup

      self
    end

    def call
      cycle_one_job
    rescue Exception => e
      tm = Time.now.strftime(Clogtimestamp)
      logger.error { "[#{tm}] #{e.class.name} #{e.message}\n\t" +
        e.backtrace.join("\n\t") + "\n\n" }
    ensure
      flush_logs if logger.respond_to?(:flush)
    end

    protected

    def cycle_one_job
      job_k = @job_cycles.shift
      unless job_k.nil?
        @job_cycles.push(job_k)
        perform_job_one_unit(jobber.jobs[job_k])
      end
    end

    def perform_job_one_unit(job)
      item = job.reserve
      unless item.nil?
        unit = item.get
        unless unit.nil?
          app = lambda do |env|
            env[:job].perform(env[:item], env[:unit])
          end

          bal_log = lambda do |env|
            benchmark_and_log(env, &app)
          end

          perform_middleware(:job => job,
                             :item => item,
                             :unit => unit,
                             &bal_log)
        else
          logger.error { "!!! Item #{item.trx_id} is gone" }
        end
      end
    end

    def perform_middleware(env, &block)
      unless @middelware.nil?
        @middleware.call(env, block)
      else
        yield(env)
      end
    end

    def flush_logs
      if defined?(EventMachine) && EventMachine.reactor_running?
        EventMachine.next_tick { logger.flush }
      else
        logger.flush
      end
    end

    def benchmark_and_log(env, &block)
      rt = nil; ret = [ false, nil ]
      job, item, unit = env[:job], env[:item], env[:unit]

      tm = Time.now.strftime(Clogtimestamp)

      params = unit[Cparams].inject({ }) do |o, (k,v)|
        case v
        when String
          o[k] = v.length > 70 ? "%s..." % v[0,70] : v
        else
          o[k] = v
        end
        o
      end

      logger.info { sprintf(Clogprocessingformat,
                            job.job_key,
                            unit[Caction],
                            item.trx_id,
                            unit[Corigin],
                            tm,
                            params.inspect) }

      rt = [ Benchmark.measure { ret = yield(env) }.real, 0.0001 ].max

      logger.info { sprintf(Clogcompletedformat,
                            rt,
                            (1 / rt).floor,
                            job.job_key,
                            unit[Caction],
                            item.trx_id) }

      ret
    end
  end
end
