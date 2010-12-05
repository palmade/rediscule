module Palmade::Rediscule
  # The DurableQueue introduces two new queues for keeping track
  # worked at items and delayed items.
  class DurableQueue < BaseQueue
    DEFAULT_OPTIONS = {
      :rt_at_interval => 60, # 60 seconds
      :rt_max_count => 20, # re-try 40 times
      :work_perform_limit => 30 # 30 seconds
    }

    attr_reader :working_cache_key
    attr_reader :retries_cache_key

    def initialize(key_prefix, options = { })
      super(key_prefix, DEFAULT_OPTIONS.merge(options))

      @working_cache_key = ("%s/working" % key_prefix).freeze
      @retries_cache_key = ("%s/retries" % key_prefix).freeze

      set_item_klass(DurableItem)
    end

    def rt_at_interval
      @options[:rt_at_interval]
    end

    def rt_max_count
      @options[:rt_max_count]
    end

    def work_perform_limit
      @options[:work_perform_limit]
    end

    # TODO: In addition to normal pop of items, enqueue the items to the
    # working queue.
    def pop
      trx_id = rcache.rpoplpush(queue_cache_key, working_cache_key)
      unless trx_id.nil? || trx_id.empty?
        ik = item_klass.new(self, trx_id)
        ik.get_meta
        ik.working!
        ik
      end
    end

    # TODO: Check overdue items.
    # Go through the 'working' queue and move them to delayed.
    def check_overdue
    end

    # TODO: Check retry items.
    # Go through the 'retries' queue and requeue when ready.
    def check_retries
    end
  end
end
