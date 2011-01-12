module Palmade::Rediscule
  class Worker
    include Constants

    attr_reader :job
    attr_reader :jobber
    attr_reader :logger
    attr_reader :item
    attr_reader :unit
    attr_reader :params

    def performed?; @item_status == :performed; end
    def performed!; @item_status = :performed; end
    def retry_later!; @item_status = :retry_later; end
    def can_retry_later?; @item.can_retry_later?; end

    def throw_performed!; throw(:performed); end

    def self.perform(job, item, unit)
      self.new(job).perform(item, unit)
    end

    def initialize(job)
      @job = job
      @jobber = job.jobber
      @logger = job.logger

      @performed = false
      @item_status = nil
    end

    def perform(item, unit)
      @unit = unit
      @item = item

      action = @unit[Caction].to_sym

      if public_methods(false).include?(action)
        perform_action(action)
      else
        # do nothing
        @item.destroy
        logger.error { "!!! #{self.class.name} does not respond to action #{action}" }

        self
      end
    end

    def perform_action(action)
      @item_status = nil
      @params = @unit[Cparams]

      before_perform

      catch(:performed) do
        send(action)
      end

      after_perform

      case @item_status
      when :retry_later
        @item.retry_later
      when :performed
        @item.destroy
      when nil
        @item.destroy
      end

      self
    end

    protected

    def before_perform; end
    def after_perform; end

    def error_exception(e)
      msg = "#{e.class.name}: #{e.message}"
      logger.error { "#{msg}\n\t#{e.backtrace.join("\n\t")}\n\n" }; msg
    end
  end
end
