module Palmade::Rediscule
  class JanitorPuppet < DaemonPuppet
    DEFAULT_OPTIONS = {
      :count => 1,
      :nap_time => 8 # 8 seconds
    }

    def initialize(options = { }, &block)
      super(DEFAULT_OPTIONS.merge(options), &block)

      @proc_tag = @proc_tag.gsub(".daemon", ".janitor")
    end

    protected

    def start_daemon
      @daemon = Janitor.start(@jobber, @job_keys, @daemon_options)
    end
  end
end
