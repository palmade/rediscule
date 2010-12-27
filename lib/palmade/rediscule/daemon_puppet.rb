module Palmade::Rediscule
  class DaemonPuppet < Palmade::PuppetMaster::EventdPuppet
    DEFAULT_OPTIONS = {
      :jobber => nil,
      :daemon_options => { },
      :job_keys => :all,
      :count => 3,
      :nap_time => 2 # 2 seconds
    }

    attr_reader :daemon

    def initialize(options = { }, &block)
      super(DEFAULT_OPTIONS.merge(options), &block)

      @jobber = @options.delete(:jobber) || Palmade::Rediscule.jobber
      @job_keys = @options[:job_keys]
      @daemon_options = @options[:daemon_options]

      if @proc_tag.nil?
        @proc_tag = "rediscule.daemon"
      else
        @proc_tag = "#{@proc_tag}.rediscule.daemon"
      end
    end

    def build!(m, fam)
      super(m, fam)
      start_daemon
    end

    def perform_work(w)
      @daemon.call
    end

    protected

    def start_daemon
      @daemon = Daemon.start(@jobber, @job_keys, @daemon_options)
    end
  end
end
