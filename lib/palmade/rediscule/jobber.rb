require 'yaml'

module Palmade::Rediscule
  class Jobber
    attr_reader :root_path
    attr_reader :env
    attr_reader :config
    attr_reader :jobs

    CDEFAULT_LOG_PATH = "log/jobber.log".freeze
    CDEFAULT_CONFIG_PATH = "config/jobber.yml".freeze

    def self.init(root_path, env)
      Palmade::Rediscule.jobber = self.new(root_path, env)
    end

    def initialize(root_path, env)
      @root_path = root_path
      @env = env
      @logger = nil
      @config = nil

      @routes = { }
      @jobs = { }
    end

    def set_logger(l)
      @logger.close unless @logger.nil?
      @logger = nil
      @logger = l
    end

    # reads and loads config files from config/jobber.yml file
    def configure(config_path = nil)
      config_path = File.join(@root_path, config_path || CDEFAULT_CONFIG_PATH)
      if File.exists?(config_path)
        @config = YAML.load_file(config_path)
      else
        raise "Config file not found. Expected: #{config_path}"
      end
    end

    def finalize
      unless @routes.empty?
        @routes.each do |job_k, options|
          case options[:type]
          when :base, 'base', nil
            job_klass = Job
          when :durable, 'durable'
            job_klass = DurableJob
          else
            raise "Unsupported job type #{options[:type]}"
          end

          @jobs[job_k] = job_klass.create(self,
                                          job_k,
                                          options)
        end
      else
        raise "Routes is empty. Please map some jobs to use Jobber"
      end
    end

    def map_job(job_k, options = { })
      @routes[job_k.to_s.dup.freeze] = options.dup
    end

    def logger
      if @logger.nil?
        @logger = Logger.new(File.join(@root_path, CDEFAULT_LOG_PATH))
      else
        @logger
      end
    end
  end
end
