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

    # In addition to normal pop of items, enqueue the items to the
    # working queue.
    def pop
      trx_id = rcache.rpoplpush(queue_cache_key, working_cache_key)
      unless trx_id.nil? || trx_id.empty?
        ik = create_item(trx_id)
        unless ik.get_meta.nil?
          ik.working!
          ik
        else
          nil
        end
      else
        nil
      end
    end

    # Return the number of items being worked on.
    def working_size
      rcache.llen(working_cache_key)
    end

    # Return the number of items waiting for retry.
    def retries_size
      rcache.llen(retries_cache_key)
    end

    def each_working(&block)
      trx_ids = rcache.lrange(working_cache_key, 0, -1)
      unless trx_ids.nil? || trx_ids.empty?
        trx_ids.each do |trx_id|
          yield create_item(trx_id)
        end
      end
    end

    def each_retries(&block)
      trx_ids = rcache.lrange(retries_cache_key, 0, -1)
      unless trx_ids.nil? || trx_ids.empty?
        trx_ids.each do |trx_id|
          yield create_item(trx_id)
        end
      end
    end

    def cleanup_overdue
      each_working do |item|
        if item.get_meta.nil?
          # we got a nil, perhaps, it's already been deleted.
          rcache.lrem(working_cache_key, 0, item.trx_id)
        end
      end
    end

    def find_overdue
      overdue = [ ]
      each_working do |item|
        unless item.get_meta.nil?
          # then push, overdue items
          overdue.push(item) if item.overdue?
        end
      end
      overdue
    end

    def cleanup_retries
      each_retries do |item|
        if item.get_meta.nil?
          rcache.lrem(retries_cache_key, 0, item.trx_id)
        end
      end
    end

    def find_retries
      retries = [ ]
      each_retries do |item|
        unless item.get_meta.nil?
          retries.push(item) if item.retry?
        end
      end
      retries
    end

    # Check overdue items.
    # Go through the 'working' queue and return overdue items.
    #
    # Implementation notes:
    # Go through each item, check meta.
    # If meta is nil, just remove from working queue.
    # If there's meta, check if overdue?
    # If overdue? append to list
    # If not, skip.
    def check_overdue
      overdue = [ ]
      each_working do |item|
        unless item.get_meta.nil?
          # then push, overdue items
          overdue.push(item) if item.overdue?
        else
          rcache.lrem(working_cache_key, 0, item.trx_id)
        end
      end
      overdue
    end

    # TODO: Check retry items.
    # Go through the 'retries' queue and requeue when ready.
    #
    # Implementation notes:
    # Go through each item, check meta.
    # If meta is nil, just remove from working queue.
    # If there's meta, check if ready for retry.
    # If ready, requeue.
    # If not, skip.
    def check_retries
      retries = [ ]
      each_retries do |item|
        unless item.get_meta.nil?
          retries.push(item) if item.retry?
        else
          # we got a nil, perhaps, it's already been deleted.
          rcache.lrem(retries_cache_key, 0, item.trx_id)
        end
      end
      retries
    end
  end
end
